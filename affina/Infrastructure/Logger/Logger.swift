//
//  Logger.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import UIKit

enum LogEvents: String {
    case debug = "✅ [DEBUG]"
    case info  = "📝 [INFO]"
    case event = "📆 [EVENT]"
    case warn  = "‼️ [WARNING]"
    case error = "🐞 [ERROR]"
}

class Logger: NSObject {
    private class func getDateTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    static func Logs(event: LogEvents = LogEvents.debug, message: Any, fileName: String = #file, funcName: String = #function, line: Int = #line) {
        #if !NDEBUG
        print("\(self.getDateTime()) \(event.rawValue) [\(sourceFileName(filePath: fileName))] \(funcName) [\(line)] - \(message)")
        #endif
    }
    
    // For beautiful logging
    static func DumpLogs(event: LogEvents = LogEvents.debug, message: Any, fileName: String = #file, funcName: String = #function, line: Int = #line) {
        #if !NDEBUG
        print("\(self.getDateTime()) \(event.rawValue) [\(sourceFileName(filePath: fileName))] \(funcName) [\(line)] - ")
        dump(message)
        #endif
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

