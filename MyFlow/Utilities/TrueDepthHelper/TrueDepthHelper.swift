//
//  TrueDepthHelper.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/02/22.
//

import AVFoundation


protocol TrueDepthHelperDelegate: AnyObject {
    /// Called whenever an TrueDepthHelper instance outputs a new average of depth data.
    /// 
    /// The result is not in Main Queue. If you want to update the UI, please do it in MainQueue.
    ///
    /// - Parameter average: the average of depth data.
    func depthDataAverageOutput(_ average: Float)
}


class TrueDepthHelper: NSObject {
    
    let logger = MyLogger(category: String(describing: TrueDepthHelper.self))
    
    
    weak var delegate: TrueDepthHelperDelegate?
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    /// The result of session setup. The session can only be started on success.
    private var setupResult: SessionSetupResult = .success
    
    /// The session that processes video input from a TrueDepth camera and returns it as depth data.
    private let session = AVCaptureSession()
    /// The session's running state.
    private var isSessionRunning = false
    /// Observation of session's isRunning.
    private var sessionObservation: NSKeyValueObservation?
    
    /// The queue for communication and manipulation of the session and related objects.
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], autoreleaseFrequency: .workItem)
    /// Callback queue for depth data output.
    private let dataOutputQueue = DispatchQueue(label: "data queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    /// The session to find built-in TrueDepth camera.
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera],
                                                                               mediaType: .video,
                                                                               position: .front)
    /// Input captured from video device.
    private var videoDeviceInput: AVCaptureDeviceInput!
    /// Output about depth data from the session.
    private let depthDataOutput = AVCaptureDepthDataOutput()
    
    
    override init() {
        super.init()
        
        configure()
        startSession()
    }
    
    deinit {
        if self.setupResult == .success {
            NotificationCenter.default.removeObserver(self)
            sessionObservation?.invalidate()
        }
    }
}


// MARK: Session Management
extension TrueDepthHelper {
    func configure() {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            setupResult = .notAuthorized
            AlertMaker.showAlert(AlertMaker.trueDepthAlert())
            return
        }
        
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    func startSession() {
        sessionQueue.async {
            if self.setupResult != .success {
                AlertMaker.showAlert(AlertMaker.trueDepthConfigurationFailAlert())
                return
            }
            self.addObservers()
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
}


// MARK: Session Configure
extension TrueDepthHelper {
    private func configureSession() {
        if setupResult != .success { return }
        
        session.beginConfiguration()
        
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        
        do {
            let videoDevice = try prepareVideoDevice()
            try prepareVideoDeviceInput(videoDevice)
            try addInput()
            try addOutput()
            try setFormat(videoDevice)
        } catch {
            logger.log(error.localizedDescription, .error)
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        depthDataOutput.setDelegate(self, callbackQueue: dataOutputQueue)
        
        session.commitConfiguration()
    }
    
    private func prepareVideoDevice() throws -> AVCaptureDevice {
        guard let videoDevice = videoDeviceDiscoverySession.devices.first else {
            throw TrueDepthError.cannotFindVideoDevice
        }
        return videoDevice
    }
    
    private func prepareVideoDeviceInput(_ videoDevice: AVCaptureDevice) throws {
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            throw TrueDepthError.cannotCreateVideoInput(error)
        }
    }
    
    private func addInput() throws {
        guard session.canAddInput(videoDeviceInput) else {
            throw TrueDepthError.cannotAddVideoInputToSession
        }
        session.addInput(videoDeviceInput)
    }
    
    private func addOutput() throws {
        if session.canAddOutput(depthDataOutput) {
            session.addOutput(depthDataOutput)
            depthDataOutput.isFilteringEnabled = false
        } else {
            throw TrueDepthError.cannotAddDepthDataOutputToSession
        }
    }
    
    private func setFormat(_ videoDevice: AVCaptureDevice) throws {
        let format = videoDevice.activeFormat.supportedDepthDataFormats
            .filter {
                CMFormatDescriptionGetMediaSubType($0.formatDescription) == kCVPixelFormatType_DepthFloat16
            }
            .max(by: { first, second in
                CMVideoFormatDescriptionGetDimensions(first.formatDescription).width < CMVideoFormatDescriptionGetDimensions(second.formatDescription).width
            })
        
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.activeDepthDataFormat = format
            videoDevice.unlockForConfiguration()
        } catch {
            throw TrueDepthError.cannotLockDeviceForConfiguration(error)
        }
    }
}


// MARK: Session Observing
extension TrueDepthHelper {
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError),
                                               name: NSNotification.Name.AVCaptureSessionRuntimeError, object: session)
        
        sessionObservation = session.observe(\.isRunning, options: .new) { [weak self] session, change in
            guard let isRunning = change.newValue else { return }
            self?.logger.log("Session running: \(isRunning)", .debug)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted),
                                               name: NSNotification.Name.AVCaptureSessionWasInterrupted,
                                               object: session)
    }
    
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            logger.log("Capture session was interrupted with reason \(reason)", .info)
        }
    }
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        logger.log("Capture session runtime error: \(error)", .error)
        
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
}


// MARK: AVCaptureDepthDataOutputDelegate
extension TrueDepthHelper: AVCaptureDepthDataOutputDelegate {
    func depthDataOutput(_ output: AVCaptureDepthDataOutput,
                         didOutput depthData: AVDepthData,
                         timestamp: CMTime,
                         connection: AVCaptureConnection) {
        let depthPixelBuffer = depthData.depthDataMap
        
        let average = calculateAverage(depthFrame: depthPixelBuffer)
        
        delegate?.depthDataAverageOutput(Float(average))
    }
    
    /// Calculates average from depthFrame.
    private func calculateAverage(depthFrame: CVPixelBuffer) -> Double {
        var sum = 0.0
        let width = CVPixelBufferGetWidth(depthFrame)
        let height = CVPixelBufferGetHeight(depthFrame)
        assert(kCVPixelFormatType_DepthFloat16 == CVPixelBufferGetPixelFormatType(depthFrame))
        CVPixelBufferLockBaseAddress(depthFrame, .readOnly)
        for row in (0..<height) {
            let rowData = (CVPixelBufferGetBaseAddress(depthFrame)!
                           + row * CVPixelBufferGetBytesPerRow(depthFrame))
                .assumingMemoryBound(to: Float16.self)
            for col in (0..<width) {
                let f = Float(rowData[col])
                if !f.isNaN {
                    sum += Double(f)
                }
            }
        }
        CVPixelBufferUnlockBaseAddress(depthFrame, .readOnly)
        return sum / Double((width - 1) * (height - 1)) * 100.0
    }
}

