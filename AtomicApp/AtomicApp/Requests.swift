//
//  Requests.swift
//  AtomicApp
//
//  Created by Omar Gomez on 6/19/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation
import FoundationLogging

class Request {
    
    let endpoint: EndPoint
    
    required init(_ endpoint: EndPoint) {
        self.endpoint = endpoint
    }
    
    func execute( completion: @escaping (Response?, Error?) -> Void ) {
        URLSession.shared.doJsonTask(forURL: self.endpoint.url) { (data, error) in
            
            guard let theData = data else {
                completion(nil, error)
                return
            }
            
            Log.info(message: String(describing: theData))
            let respType = self.endpoint.responseType
            let response = respType.init(fromJson: theData)
            Log.info(message: String(describing: response))
            
            completion(response, error)
            
        }
    }
}

class NowPlayingRequest: Request {
}
