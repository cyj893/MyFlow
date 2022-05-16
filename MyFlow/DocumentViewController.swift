//
//  DocumentViewController.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/05/13.
//

import UIKit
import SnapKit

import PDFKit

class DocumentViewController: UIViewController, PDFDocumentDelegate {
    let myNavigationView = MyNavigationView.singletonView
    var pdfView = PDFView()
    var document: UIDocument?
    var isShowingMyNavigationView: Bool = true
    var points:[(PDFPage, CGFloat)] = []
    
    var idx:Int = 0
    
    let gradientColors:[UIColor] = [UIColor(rgb: 0x769FCD, alpha: 0.5),
                                    UIColor(rgb: 0xB9D7EA, alpha: 0.5),
                                    UIColor(rgb: 0xD6E6F2, alpha: 0.5),
                                    UIColor(rgb: 0xF7FBFC, alpha: 0.5)]
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open(completionHandler: { (success) in
            if success {
                print("success")
                let pdfDocument = PDFDocument(url: self.document!.fileURL)!
                pdfDocument.delegate = self
                self.pdfView.document = pdfDocument
                if pdfDocument.allowsCommenting == false {
                    // TODO: presenting an message to the user.
                    print("This file cannot be commented")
                }
            }
            else {
                print("error")
                // TODO: presenting an error message to the user.
            }
        })
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myNavigationView.setCurrentVC(vc: self)
        view.addSubview(myNavigationView)
        myNavigationView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        
        view.addSubview(pdfView)
        pdfView.snp.makeConstraints {
            $0.top.equalTo(myNavigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(false)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        
        pdfView.backgroundColor = .black
        
        addTapGesture()
        
    }
        
    func prevPointButtonAction() {
        print("prevPointButtonAction")
        idx += -1 + points.count
        idx %= points.count
        let now = points[idx]
        print(idx)
        pdfView.go(to: CGRect(origin: CGPoint(x: 0, y: now.1), size: CGSize(width: 1, height: -view.frame.height)), on: now.0)
    }
    func nextPointButtonAction() {
        print("nextPointButtonAction")
        idx += 1
        idx %= points.count
        let now = points[idx]
        print(idx)
        pdfView.go(to: CGRect(origin: CGPoint(x: 0, y: now.1), size: CGSize(width: 1, height: -view.frame.height)), on: now.0)
    }
    
}

// MARK: Define Tap Gesture
extension DocumentViewController {
    
    fileprivate func addTapGesture() {
        let taps = UITapGestureRecognizer(target: self, action: #selector(setTapGesture))
        pdfView.addGestureRecognizer(taps)
    }
    
    @objc func setTapGesture(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: pdfView)
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        let convertedLocation = pdfView.convert(location, to: page)
        
        if myNavigationView.getIsHandlingPoints() {
            handlePoints(convertedLocation, page)
            return
        }
        if myNavigationView.getIsAddingPoints() {
            addPoint(convertedLocation.y, page)
            return
        }
        if isShowingMyNavigationView {
            hideNavigationView()
            isShowingMyNavigationView = false
        }
        else {
            showNavigationView()
            isShowingMyNavigationView = true
        }
    }
    
}

// MARK: Toggle NavigationView
extension DocumentViewController {
    
    fileprivate func showNavigationView() {
        print("show myNavigationView")
        myNavigationView.snp.remakeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        pdfView.snp.remakeConstraints {
            $0.top.equalTo(myNavigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        animateIt()
    }
    
    fileprivate func hideNavigationView() {
        print("hide myNavigationView")
        myNavigationView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(-100)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        pdfView.snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
        
        animateIt()
    }
    
    fileprivate func animateIt() {
        UIView.animate(
            withDuration: 0.5,
            animations: self.view.layoutIfNeeded
        )
    }
}


// MARK: Handle Points

extension DocumentViewController {
    
    fileprivate func handlePoints(_ convertedLocation: CGPoint, _ page: PDFPage) {
        guard let annotation = page.annotation(at: convertedLocation) else { return }
        guard let _ = annotation.annotationKeyValues["/isPoint"] else { return }
        print(annotation)
    }
    
}


// MARK: Add the Point

extension DocumentViewController {
    
    fileprivate func addPoint(_ height: CGFloat, _ page: PDFPage) {
        points.append((page, height))
        addPointLineGradient(height, page)
    }
    
    fileprivate func addPointLine(_ heightPoint: CGPoint, _ page: PDFPage, color: UIColor = .blue) {
        let path = UIBezierPath()
        path.move(to: heightPoint)
        let pageSize = page.bounds(for: PDFDisplayBox.mediaBox).size
        path.addLine(to: CGPoint(x: pageSize.width, y: heightPoint.y))
        path.close()
        
        let border = PDFBorder()
        border.lineWidth = 1.0
        
        let bounds = CGRect(x: path.bounds.origin.x - 5,
                            y: path.bounds.origin.y - 5,
                        width: path.bounds.size.width + 10,
                       height: path.bounds.size.height + 10)
        path.moveCenter(to: bounds.center)
        
        let inkAnnotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: ["isPoint": true])
        inkAnnotation.add(path)
        inkAnnotation.border = border
        inkAnnotation.color = color
        page.addAnnotation(inkAnnotation)
    }
    
    fileprivate func addPointLineGradient(_ height: CGFloat, _ page: PDFPage) {
        for i in 0...3 {
            addPointLine(CGPoint(x: 0.0, y: height - CGFloat(i)), page, color: gradientColors[i])
        }
        addNumber(height, page)
    }
    
    fileprivate func addNumber(_ height: CGFloat, _ page: PDFPage) {
        let str = "123"
        let font = UIFont.Fonarto(size: 20)
        let size = str.sizeOfString(font: font!)
        let pointNumText = PDFAnnotation(bounds: CGRect(origin: CGPoint(x: 10.0, y: height - size.height), size: size), forType: .widget, withProperties: nil)
        
        pointNumText.widgetStringValue = str
        pointNumText.widgetFieldType = .text
        
        pointNumText.alignment = .center
        pointNumText.font = font
        pointNumText.fontColor = .systemPink
        pointNumText.color = .clear
        pointNumText.backgroundColor = .clear
        
        page.addAnnotation(pointNumText)
    }
    
}
