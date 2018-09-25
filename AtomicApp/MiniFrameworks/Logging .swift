//
//  Logging .swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 9/21/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

protocol LoggeableApp {
    func appDefaultLevel() -> LogLevel
}

extension LoggeableApp {
    
    func appDefaultLevel() -> LogLevel {
        return .DEBUG
    }
    
}

enum LogLevel:Int, LoggeableApp {

    case DEBUG = 0
    case INFO = 1
    case WARN = 2
    case ERROR = 3
    case CRITICAL = 4
    
    func logMessage(_ msg: String, _ error: Error? = nil ) {
        
        guard self.rawValue >= appDefaultLevel().rawValue else {
            return
        }
        
        let levelName: String = {
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
        }()
        
        if let error = error {
            print("[\(levelName)]: \"\(msg)\" (\(String(describing: error))")
        }
        else {
            print("[\(levelName)]: \"\(msg)\"")
        }
        
    }
    
}
