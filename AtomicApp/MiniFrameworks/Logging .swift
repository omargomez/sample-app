//
//  Logging .swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 9/21/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

protocol LoggeableApp {
    func appDefaultLevel() -> Logger.Level
    func prefix(_ level: Logger.Level) -> String
}

extension LoggeableApp {
    
    func appDefaultLevel() -> Logger.Level {
        return .DEBUG
    }
    
    func prefix(_ level: Logger.Level) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss:SSS"

        let process = ProcessInfo.processInfo
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)
        return "\(level) \(dateFormatter.string(from: Date())) \(process.processName) [\(process.processIdentifier):\(threadID)]"
    }
    
}

final class Logger: LoggeableApp {
    
    enum Level: Int, CustomStringConvertible {
        case DEBUG = 0
        case INFO = 1
        case WARN = 2
        case ERROR = 3
        case CRITICAL = 4
        
        public var description: String {
            switch self {
            case .DEBUG:
                return "DEBUG"
            case .INFO:
                return "INFO"
            case .WARN:
                return "WARN"
            case .ERROR:
                return "ERROR"
            case .CRITICAL:
                return "CRITICAL"
            }
        }
        
    }
    
    public static let shared = Logger()
    
    func log(_ level: Level, _ msg: String, _ error: Error? = nil) {
        
        guard level.rawValue >= appDefaultLevel().rawValue else {
            return
        }
        
        var output = "\(prefix(level)) \"\(msg)\""
        
        if let error = error {
            output += " (\(String(describing: error))"
        }
        
        print(output)

    }
    
    func debug<T>(_ msg: T, _ error: Error? = nil) {
        self.log(.DEBUG, String(describing: msg), error)
    }
    
    func info<T>(_ msg: T, _ error: Error? = nil) {
        self.log(.INFO, String(describing: msg), error)
    }
    
    func warn<T>(_ msg: T, _ error: Error? = nil) {
        self.log(.WARN, String(describing: msg), error)
    }
    
    func error<T>(_ msg: T, _ error: Error? = nil) {
        self.log(.ERROR, String(describing: msg), error)
    }
    
    func critical<T>(_ msg: T, _ error: Error? = nil) {
        self.log(.CRITICAL, String(describing: msg), error)
    }

}
