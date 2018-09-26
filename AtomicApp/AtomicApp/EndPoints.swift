//
//  EndPoints.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/25/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

enum EndPoint {
    
    static let baseURL = "https://api.themoviedb.org"
    static let apiKey = "1e7e61e962607b1d22d9908e764ff14e"
    static let version = 3
    
    case nowPlaying
    case configuration
    case genres
    case image(basePath:String, size: String, imageName: String)
    case movie(movieId:String)
    case credits(movieId:String)
    
    var url: URL {
        switch self {
        case .nowPlaying:
            return URL(string: String(format: "%@/%d/movie/now_playing?page=1&language=en-US&api_key=%@", EndPoint.baseURL, EndPoint.version, EndPoint.apiKey))!
        case .configuration:
            return URL(string: String(format: "%@/%d/configuration?&api_key=%@", EndPoint.baseURL, EndPoint.version, EndPoint.apiKey))!
        case .genres:
            return URL(string: String(format: "%@/%d/genre/movie/list?&api_key=%@", EndPoint.baseURL, EndPoint.version, EndPoint.apiKey))!
        case .image(let basePath, let size, let name):
            return URL(string: String(format: "%@%@%@", basePath, size, name))!
        case .movie(let movieId):
            return URL(string: String(format: "%@/%d/movie/%@?&api_key=%@", EndPoint.baseURL, EndPoint.version, movieId, EndPoint.apiKey))!
        case .credits(let movieId):
            let str = String(format: "%@/%d/movie/%@/credits?&api_key=%@", EndPoint.baseURL, EndPoint.version, movieId, EndPoint.apiKey)
            Logger.shared.debug("Credits url: \(str)")
            return URL(string: String(format: "%@/%d/movie/%@/credits?&api_key=%@", EndPoint.baseURL, EndPoint.version, movieId, EndPoint.apiKey))!
        }
    }

}

