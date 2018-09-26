//
//  URLSession+Extensions.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/25/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation
import UIKit

extension URLSession {
    
    enum JsonError: Error {
        case noDataError
        case parsingError
    }
    
    enum ImageError: Error {
        case noDataError
        case creationError
    }
    
    func doJsonTask(forURL endpoint: URL, completion: @escaping (_ data: [String: Any]?, _ error: Error?) -> Void ) {
        
        let task = URLSession.shared.dataTask(with: endpoint) {(data, response, error ) in
            
            guard error == nil else {
                Logger.shared.error("returned error")
                completion(nil, error)
                return
            }
            
            guard let content = data else {
                completion(nil, JsonError.noDataError)
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                completion(nil, JsonError.parsingError)
                return
            }
            
            completion(json, nil)
            
        }
        
        task.resume()
        
    }
    
    func createImageTask(fromURL imageURL: URL, completion: @escaping (UIImage?, Error?) -> Void ) -> URLSessionTask {
        
        let task = URLSession.shared.dataTask(with: imageURL) {(data, response, error ) in
            
            guard error == nil else {
                Logger.shared.error("returned error")
                completion(nil, error)
                return
            }
            
            guard let imageData = data else {
                completion(nil, ImageError.noDataError)
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                completion(nil, ImageError.creationError)
                return
            }
            
            completion(image, nil)
            
        }
        
        return task
        
    }
    
    func doImageTask(fromURL imageURL: URL, completion: @escaping (UIImage?, Error?) -> Void ) {
        
        let task = createImageTask(fromURL: imageURL, completion: completion)
        task.resume()
        
    }
}

