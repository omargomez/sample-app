//
//  Logger.swift
//  AtomicApp
//
//  Created by Omar Gomez on 10/1/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

protocol LoggerOutputStrategy {
    
    func configure(_ callback: (Error?) -> Void)
    var isConfigured: Bool { get }
    func write(_ logLine: String)
    
}

protocol LoggerFormatter {
    
    func format(_ date: Date, _ uuid: UUID, _ level: Logger.Level, _ msg: String, _ error: Error?) -> String

}

final class DefaultFormatter: LoggerFormatter {
    
    func format(_ date: Date, _ uuid: UUID, _ level: Logger.Level, _ msg: String, _ error: Error?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss.SSS"
        let process = ProcessInfo.processInfo
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)
        var result = "\(level) \(dateFormatter.string(from: Date())) \(process.processName) [\(process.processIdentifier):\(threadID)] \"\(msg)\""
        if let error = error {
            result += "(\(error))"
        }
        
        return result
    }
}

extension LoggerOutputStrategy {
    
    func configure(_ callback: (Error?) -> Void) {}
    
    var isConfigured: Bool {
        return false
    }
}

class Logger {
    
    enum Level: Int {
        case INFO = 0
        case DEBUG = 1
        case ERROR = 9
        case CRITICAL = 10
    }
    
    enum Extension {
        case REPLACE
        case APPEND
    }

    let parent: Logger?
    let outputStrategy: LoggerOutputStrategy
    let level: Level
    let formatter: LoggerFormatter
    
    static let shared = Logger(extendAs: .REPLACE, output: LoggerConsoleOutputStrategy())
    
    init(from parentLogger: Logger? = nil, extendAs: Extension, output: LoggerOutputStrategy, _ level: Level = .INFO, _ formatter: LoggerFormatter = DefaultFormatter()) {
        self.parent = parentLogger
        self.outputStrategy = output
        self.level = level
        self.formatter = formatter
    }
    
    func log<T>(_ level: Level, _ msg: T, _ error: Error? = nil) {
        let logMoment = Date()
        let uuid = UUID()
        DispatchQueue.global(qos: .default).async { [weak self] in
            self?.process(logMoment, uuid, level, String(describing:msg), error)
        }
    }
    
    func process(_ date: Date, _ uuid: UUID, _ level: Level, _ msg: String, _ error: Error? = nil) {
        if level.rawValue >= self.level.rawValue {
            
            if !self.outputStrategy.isConfigured {
                
                self.outputStrategy.configure { (error) in
                    if let error = error {
                        let logger = self.parent ?? Logger.shared
                        logger.log(.ERROR, "Error while configuring output strategy", error)
                    } else {
                        DispatchQueue.global(qos: .default).async { [weak self] in
                            self?.process(date, uuid, level, msg, error)
                        }
                    }
                    return
                }
            }
            // Prefix and posfix
            // config check
            let finalMsg = self.formatter.format(date, uuid, level, msg, error)
            self.outputStrategy.write(finalMsg)
        }
    }
    
}

class LoggerConsoleOutputStrategy: LoggerOutputStrategy {
    
    static let consoleQueue  = DispatchQueue(label: "logger.console")
    
    var isConfigured: Bool {
        return true
    }

    func write(_ logLine: String) {
        LoggerConsoleOutputStrategy.consoleQueue.sync {
            print(logLine)
        }
    }

}
