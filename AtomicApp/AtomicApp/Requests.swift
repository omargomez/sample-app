//
//  Requests.swift
//  AtomicApp
//
//  Created by Omar Gomez on 6/19/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

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
            
            debugPrint(theData)
            let respType = self.endpoint.responseType
            let response = respType.init(fromJson: theData)
            debugPrint(response)
            
            completion(response, error)
            
        }
    }
}

class NowPlayingRequest: Request {
}
