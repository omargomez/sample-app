//
//  MovieDBConfig.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/27/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation
import FoundationLogging

class MovieDBConfig
{
    public static let shared = MovieDBConfig(false)
    
    private var configured: Bool
    private var configDict: [String:Any]!

    init(_ configured: Bool) {
        self.configured = configured
    }
    
    public func refresh() {
    
        URLSession.shared.doJsonTask(forURL: EndPoint.configuration.url) { (data, error) in
    
            DispatchQueue.main.async { [unowned self] in
                
                guard let theData = data else {
                    Log.error(error: error ?? NSError.UNKNOWN)
                    return
                }
                
                self.configDict = theData
                self.configured = true
                
                Log.info(message: "[CONF]: \(theData.description)")

            }
    
        }

    }
    
    public func getImagesBasePath() -> String! {
        
        guard let dict = self.configDict,
        let imagesDict = dict["images"] as? [String:Any],
        let result = imagesDict["secure_base_url"] as? String else {
            return nil
        }
        
        return result
    }
    
    public func getImagesDefaultSize() -> String! {
        guard let dict = self.configDict,
            let imagesDict = dict["images"] as? [String:Any],
            let logoArr = imagesDict["logo_sizes"] as? [String] else {
                return nil
        }
        
        let resultArr = logoArr.filter {
            return $0 == "w154"
        }
        
        guard let result = resultArr.first else {
            return logoArr.first
        }
        
        return result
    }
    
    public func getPosterDefaultSize() -> String! {
        guard let dict = self.configDict,
            let imagesDict = dict["images"] as? [String:Any],
            let posterArr = imagesDict["poster_sizes"] as? [String] else {
                return nil
        }
        
        let resultArr = posterArr.filter {
            return $0 == "w780"
        }
        
        guard let result = resultArr.first else {
            return posterArr.first
        }
        
        return result
    }
    
}
