//
//  FileHelper.swift
//  MyFlow
//
//  Created by Yujin Cha on 2022/11/23.
//

import UIKit

struct PointsFile: Codable {
    var fileUrl: String
    var key: Int
}

struct PointsInfo: Codable {
    var height: Int
    var page: Int
}

/// Manages file read/write.
///
/// If there is previously edited information, read it.
/// Save edited point information with the file path as identifier.
class FileHelper {
    
    let logger = MyLogger(category: String(describing: FileHelper.self))
    
    static let shared = FileHelper()
    let fileManager: FileManager
    let documentsURL: URL
    let directoryURL: URL
    let pointsDictPath: URL
    
    var dict: [PointsFile] = []

    private init() {
        fileManager = FileManager.default
        documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        directoryURL = documentsURL.appendingPathComponent("points")
        pointsDictPath = directoryURL.appendingPathComponent("points")
        
        makeDirectoryIfNeeded()
        
        dict = readPointsDict()
    }
    
    private func readPointsDict() -> [PointsFile] {
        do {
            let data = try Data(contentsOf: pointsDictPath)
            let dict = try JSONDecoder().decode([PointsFile].self, from: data)
            logger.log("Find PointsFileDict")
            return dict
        } catch let e {
            logger.log("Fail to find PointsFileDict: \(e.localizedDescription)", .info)
            return []
        }
    }
    
    private func makeDirectoryIfNeeded() {
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false, attributes: nil)
        } catch CocoaError.fileWriteFileExists {
            logger.log("directory(\(directoryURL.lastPathComponent)) already exists")
        } catch let e {
            logger.log("Fail to make directory: \(e.localizedDescription)", .error)
        }
    }
    
    func readPointsFileIfExist(absoluteString: String) -> [PointsInfo]? {
        if let pointsFile = dict.first(where: { $0.fileUrl == absoluteString }) {
            logger.log("Find PointsFile: \(pointsFile.fileUrl.components(separatedBy: "/").last ?? "nil")")
            let pointsFilePath = directoryURL.appendingPathComponent("\(pointsFile.key)")
            do {
                let data = try Data(contentsOf: pointsFilePath)
                let pointsInfos = try JSONDecoder().decode([PointsInfo].self, from: data)
                logger.log("Find PointsInfos: \(pointsInfos)")
                return pointsInfos
            } catch let e {
                logger.log("Cannot read PointsFile: \(e.localizedDescription)", .error)
                return nil
            }
        }
        logger.log("There's no PointsFile", .info)
        return nil
    }
    
    func writePointsFile(absoluteString: String, pointsInfos: [PointsInfo]) {
        let pointsFile = dict.first(where: { $0.fileUrl == absoluteString }) ?? addNewPointsFile(absoluteString: absoluteString)
        
        let pointsFilePath = directoryURL.appendingPathComponent("\(pointsFile.key)")
        do {
            let jsonData = try JSONEncoder().encode(pointsInfos)
            try jsonData.write(to: pointsFilePath)
        } catch {
            logger.log("Error writing PointsFile to JSON file: \(error)", .error)
        }
    }
    
    private func addNewPointsFile(absoluteString: String) -> PointsFile {
        let pointsFile = PointsFile(fileUrl: absoluteString, key: dict.count + 1)
        dict.append(pointsFile)
        writePointsDict()
        return pointsFile
    }
    
    private func writePointsDict() {
        do {
            let jsonData = try JSONEncoder().encode(dict)
            try jsonData.write(to: pointsDictPath)
        } catch {
            logger.log("Error writing PointsDict to JSON file: \(error)", .error)
        }
    }
    
}

