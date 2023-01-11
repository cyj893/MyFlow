//
//  MyLogger.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/01/11.
//

import os


struct MyLogger {
    static let subsystem = "com.chayujin.MyFlow"
    var category: String
    
    let logger: Logger
    
    
    static let defaultLogger = Logger(subsystem: MyLogger.subsystem, category: "Common")
    
    
    init(category: String) {
        self.category = category
        logger = Logger(subsystem: MyLogger.subsystem, category: category)
    }
    
    func log(_ message: String, _ level: OSLogType = .debug) {
#if DEBUG
        if level == .error || level == .fault {
            fatalError(message)
        }
#endif
        logger.log(level: level, "\(message)")
    }
    
    static func log(_ message: String, _ level: OSLogType = .debug) {
#if DEBUG
        if level == .error || level == .fault {
            fatalError(message)
        }
#endif
        defaultLogger.log(level: level, "\(message)")
    }
}
