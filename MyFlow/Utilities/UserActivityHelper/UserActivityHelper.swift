//
//  UserActivityHelper.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/01/29.
//

import Foundation


struct UserActivityHelper {
    static let logger = MyLogger(category: String(describing: MainViewController.self))
}


// MARK: Convert `[DocumentTabInfo]` to `NSUserActivity`
extension UserActivityHelper {
    static func convert(from infos: [DocumentTabInfo], nowIndex: Int) -> NSUserActivity {
        let userActivity = NSUserActivity(activityType: SceneDelegate.MainSceneActivityType)
        userActivity.addUserInfoEntries(from: ["bookmarks": infos.map { getBookmark(from: $0.url) },
                                               "xOffsets": infos.map { $0.offset.x },
                                               "yOffsets": infos.map { $0.offset.y },
                                               "scaleFactors": infos.map { $0.scaleFactor },
                                               "nowIndex": nowIndex])
        return userActivity
    }
    
    private static func getBookmark(from url: URL?) -> Data? {
        guard let url = url else {
            logger.log("url is nil", .error)
            return nil
        }
        do {
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            return bookmarkData
        } catch let error {
            logger.log(error.localizedDescription, .error)
        }
        return nil
    }
}


// MARK: Convert `NSUserActivity` to `MyUserActivity`
extension UserActivityHelper {
    static func convert(from activity: NSUserActivity) -> MyUserActivity? {
        guard let bookmarks = activity.userInfo?["bookmarks"] as? [Data?],
              let xOffsets = activity.userInfo?["xOffsets"] as? [CGFloat],
              let yOffsets = activity.userInfo?["yOffsets"] as? [CGFloat],
              let scaleFactors = activity.userInfo?["scaleFactors"] as? [CGFloat],
              let nowIndex = activity.userInfo?["nowIndex"] as? Int else {
            logger.log("Fail to read userInfo")
            return nil
        }
        
        let compactArr = zip(bookmarks, zip(xOffsets, zip(yOffsets, scaleFactors)))
            .map { ($0, CGPoint(x: $1.0, y: $1.1.0), $1.1.1) }
            .compactMap { (bookmark, point, scaleFactor) -> (URL, CGPoint, CGFloat)? in
                if let bookmark = bookmark,
                   let url = getURL(from: bookmark) {
                    return (url, point, scaleFactor)
                }
                return nil
            }
        
        return MyUserActivity(urls: compactArr.map { $0.0 },
                              points: compactArr.map { $0.1 },
                              scaleFactors: compactArr.map { $0.2 },
                              nowIndex: nowIndex)
    }
    
    private static func getURL(from bookmark: Data) -> URL? {
        do {
            var isStale = false
            var url = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)
            if isStale {
                logger.log("Bookmark(\(url.lastPathComponent)) is stale")
                let updatedBookmark = try url.bookmarkData()
            }
            return url
        } catch let error {
            logger.log("getURL from bookmark: \(error.localizedDescription)", .error)
        }
        return nil
    }
}
