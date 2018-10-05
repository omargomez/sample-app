//
//  LoggerHttpOutputStrategy.swift
//  AtomicApp
//
//  Created by Omar Gomez on 10/4/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

class LoggerHttpOutputStrategy: LoggerOutputStrategy {
    
    static let httpQueue  = DispatchQueue(label: "logger.http")
    static let resetSemaphore = DispatchSemaphore(value: 0)
    
    let httpURL: URL

    init(_ outputHttpURL: URL) {
        httpURL = outputHttpURL
    }
    
    var isConfigured: Bool {
        return true
    }
    
    func write(_ logLine: String) {
        
        LoggerHttpOutputStrategy.httpQueue.async { [weak self] in
            self?.post(logLine)
        }
        
    }
    
    private func post(_ logLine: String) {
        let url = httpURL
        var request = URLRequest(url: url)
        request.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = logLine
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                LoggerHttpOutputStrategy.resetSemaphore.signal()
            }
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                Logger.shared.log(.ERROR, "dataTask returned Error", error)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                Logger.shared.log(.ERROR, "statusCode should be 200, but is \(httpStatus.statusCode)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                Logger.shared.log(.INFO, "responseString = \(responseString)")
            }
        }
        task.resume()
        LoggerHttpOutputStrategy.resetSemaphore.wait()
    }
    
}

