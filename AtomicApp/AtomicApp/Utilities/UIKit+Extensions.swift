//
//  UIKit+Extensions.swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 6/10/20.
//  Copyright © 2020 Omar Gómez. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func loadData(loadConfig: Bool, completion: @escaping (Configuration?, [Movie]?) -> Void ) {
        
        let group = DispatchGroup()
        
        var configuration: Configuration?
        if loadConfig {
            group.enter()
            URLSession.shared.doJsonTask(forURL: EndPoint.configuration.url) { (data, error) in
                
                defer {
                    group.leave()
                }
                
                guard let theData = data else {
                    Logger.shared.log( .ERROR, "Error starting App!!!", error ?? NSError.UNKNOWN )
                    return
                }
                
                Logger.shared.log(.DEBUG, "[CONF] config: \(theData.description)")
                configuration = Configuration(fromJson: theData)
                Logger.shared.log(.DEBUG, "[CONF] app config: \(configuration!)")
            }
        }
        
        group.enter()
        var movies: [Movie]?
        URLSession.shared.doJsonTask(forURL: EndPoint.nowPlaying.url) { (data, error) in
            movies = []
            defer {
                group.leave()
            }
            
            guard let theData = data,
                let results = theData["results"] as? [Any] else {
                    Logger.shared.log(.ERROR, "Error starting App!!!", error ?? NSError.UNKNOWN)
                    return
            }
            Logger.shared.log(.DEBUG, "[CONF] now playing: \(theData.description)")
            
            for case let movieJson as [String:Any] in results {
                
                guard let movie = Movie(fromJson: movieJson) else {
                    return
                }
                
                movies?.append(movie)
            }
            
        }
        
        group.notify(queue: .main) {
            
            completion(configuration, movies)
        }
        
    }
    
}
