//
//  LoggerFileOutputStrategy.swift
//  AtomicApp
//
//  Created by Omar Gomez on 10/1/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

class LoggerFileOutputStrategy: LoggerOutputStrategy {
    
    static let fileQueue  = DispatchQueue(label: "logger.file")
    
    let fileURL: URL
    var handle: FileHandle?
    
    init(_ outputFileURL: URL) {
        fileURL = outputFileURL
    }
    
    var isConfigured: Bool {
        return true
    }

    func write(_ logLine: String) {
        
        LoggerFileOutputStrategy.fileQueue.async { [weak self] in
            self?.doWrite(logLine)
        }

    }
    
    private func doWrite(_ logLine: String) {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            guard FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil) else {
                Logger.shared.log(.ERROR, "File couldn't be created")
                return
            }
        }
        
        guard let handle = try? FileHandle(forWritingTo: fileURL) else {
            Logger.shared.log(.ERROR, "File open failed (\(fileURL)")
            return
        }
        
        defer {
            handle.closeFile()
            Logger.shared.log(.DEBUG, "File closed! (\(fileURL)")
        }
        
        handle.seekToEndOfFile()
        handle.write(logLine.data(using: .utf8)!)
        handle.write("\n".data(using: .utf8)!)
    }

}

