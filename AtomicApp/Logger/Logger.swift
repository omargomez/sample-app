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
    
    static let shared = Logger(extendAs: .REPLACE, output: LoggerConsoleOutputStrategy())
    
    init(from parentLogger: Logger? = nil, extendAs: Extension, output: LoggerOutputStrategy, _ level: Level = .DEBUG ) {
        self.parent = parentLogger
        self.outputStrategy = output
        self.level = level
    }
    
    func log<T>(_ level: Level, _ msg: T, _ error: Error? = nil) {
        let logMoment = Date()
        DispatchQueue.global(qos: .default).async { [weak self] in
            self?.process(logMoment, level, String(describing:msg), error)
        }
    }
    
    func process(_ date: Date, _ level: Level, _ msg: String, _ error: Error? = nil) {
        if level.rawValue >= self.level.rawValue {
            
            if !self.outputStrategy.isConfigured {
                
                self.outputStrategy.configure { (error) in
                    if let error = error {
                        let logger = self.parent ?? Logger.shared
                        logger.log(.ERROR, "Error while configuring output strategy", error)
                    } else {
                        DispatchQueue.global(qos: .default).async { [weak self] in
                            self?.process(date, level, msg, error)
                        }
                    }
                    return
                }
            }
            // Prefix and posfix
            // config check
            let finalMsg = "[LOGGER] \(msg)"
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
