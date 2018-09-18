//
//  MovieDBGenres.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/28/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation
import FoundationLogging

class MovieDBGenres
{
    public static let shared = MovieDBGenres()

    private var genresData: [String:Any]!
    private var genreMap: [Int:String]!
    
    public func refresh() {
        
        URLSession.shared.doJsonTask(forURL: EndPoint.genres.url) { (data, error) in
            
            DispatchQueue.main.async { [unowned self] in
                
                guard let theData = data else {
                    Log.error(error: error ?? NSError.UNKNOWN)
                    return
                }

                guard let genresArr = theData["genres"] as? [Any] else {
                    return
                }

                self.genreMap = [:]
                
                for genreItem in genresArr {
                    guard let genre = genreItem as? [String:Any] else {
                        return
                    }
                    
                    guard let genreId = genre["id"] as? Int,
                        let genreName = genre["name"] as? String else {
                            return
                    }
                    
                    self.genreMap[genreId] = genreName
                }

                Log.info(message: "[GENRES]: \(self.genreMap.description)")
                
            }
            
        }
        
    }
    
    public func getTitles(fromIDs: [Int]) -> [String]? {
        
        guard let genres = self.genreMap else {
            return nil
        }
       
        var result: [String] = []
        
        for genreId in fromIDs {
            guard let genreName = genres[genreId] else {
                continue
            }
            
            result.append(genreName)
        }

        return result
        
    }
    
    
    
}
