//
//  Entities.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/29/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

struct Movie: Hashable {
    
    var genreIds: [Int]
    var posterPath: String
    var releaseDate: String
    var title: String
    var id: String
    
    // Failable initializer...
    init?(fromJson json: [String:Any]) {
        
        if let relDate = json["release_date"] as? String,
        let title = json["title"] as? String,
        let image = json["poster_path"] as? String,
        let genresArr = json["genre_ids"] as? [Int],
        let movieID = json["id"] as? Int {
            
            self.genreIds = genresArr
            self.posterPath = image
            self.releaseDate = relDate
            self.title = title
            self.id = String(movieID)
            
        } else {
            return nil
        }
        
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
}

struct MovieDetail {
    
    var backdropPath: String
    var title: String
    var overview: String
    var releaseDate: Date
    var genres: [String]
    
    init?(fromJson json: [String:Any]) {
        
        if let backdropPath = json["backdrop_path"] as? String,
        let title = json["title"] as? String,
        let overview = json["overview"] as? String,
        let releaseDateString = json["release_date"] as? String,
        let genreArr = json["genres"] as? [Any] {
            
            self.backdropPath = backdropPath
            self.title = title
            self.overview = overview
            
            // Parse date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: releaseDateString) {
                self.releaseDate = date
            } else {
                return nil
            }
            
            //genres
            var genres: [String] = []
            for genreItem in genreArr {
                if let genreDict = genreItem as? [String:Any] {
                    if let name = genreDict["name"] as? String {
                        genres.append(name)
                    }
                }
            }
            
            self.genres = genres

        } else {
            return nil
        }
        
    }
    
}

struct Crew {
    
    var id: String
    var cast: [CastPerson]
    var crew: [CrewPerson]
    
    init?(fromJson json: [String:Any]) {
        
        if let id = json["id"] as? Int,
        let castArr = json["cast"] as? [Any],
            let crewArr = json["crew"] as? [Any] {
            
            self.id = String(id)
            
            self.cast = []
            for case let castJson as [String:Any] in castArr {
                if let castItem = CastPerson(fromJson: castJson) {
                    self.cast.append(castItem)
                } else {
                    return nil
                }
            }
            
            self.crew = []
            for case let crewJson as [String:Any] in crewArr {
                if let crewItem = CrewPerson(fromJson: crewJson) {
                    self.crew.append(crewItem)
                } else {
                    return nil
                }
            }

        } else {
            
            return nil
        }
    }
    
    func getDirectors() -> [String] {
        
        let directors = self.crew.filter {
            return $0.job == "Director"
            }.map {
                return $0.name
        }
        
        return directors
        
    }
    
    func getWriters() -> [String] {
        
        let directors = self.crew.filter {
            return $0.job == "Screenplay" || $0.job == "Writer"
        }.map {
            return $0.name
        }
        
        return directors
        
    }
    
    func getMainCast() -> [String] {
        
        let mapped = self.cast.sorted(by: {
            return $0.order < $1.order
        }).map {
            return $0.name
        }
        
        let maxIdx = (mapped.count >= 3) ? 3 : mapped.count
        return Array<String>(mapped[..<maxIdx])
    }
    
}

struct CastPerson {
    
    var id: String
    var name: String
    var order: Int

    init?(fromJson json: [String:Any]) {
        
        if let id = json["id"] as? Int,
        let name = json["name"] as? String,
        let order = json["order"] as? Int {
            
            self.id = String(id)
            self.name = name
            self.order = order
            
        } else {
            return nil
        }
    }
}

struct CrewPerson {
    
    var id: String
    var name: String
    var job: String
    
    init?(fromJson json: [String:Any]) {
        
        if let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let job = json["job"] as? String {
            
            self.id = String(id)
            self.name = name
            self.job = job
            
        } else {
            return nil
        }
    }
}

struct Configuration {
    
    struct Images {
        
        var baseUrl: String
        var secureBaseUrl: String
        var logoSizes: [String]
        var posterSizes: [String]

        var defaultLogoSize: String {
            
            let resultArr = logoSizes.filter {
                return $0 == "w154"
            }
            
            guard let result = resultArr.first else {
                return logoSizes.first!
            }
            
            return result
        }
        
        var defaultPosterSize: String {
            
            let resultArr = posterSizes.filter {
                return $0 == "w780"
            }
            
            guard let result = resultArr.first else {
                return posterSizes.first!
            }
            
            return result
        }
        
        init?(fromJson json: [String:Any]) {
            
            guard let baseUrl = json["base_url"] as? String,
            let secureBaseUrl = json["secure_base_url"] as? String,
            let logoSizes = json["logo_sizes"] as? [String],
            let posterSizes = json["poster_sizes"] as? [String] else {
                return nil
            }
            
            self.baseUrl = baseUrl
            self.secureBaseUrl = secureBaseUrl
            self.logoSizes = logoSizes
            self.posterSizes = posterSizes
        }
        
    }
    
    var images: Images
    
    init?(fromJson json: [String:Any]) {
        
        guard let imagesJson = json["images"] as? [String:Any],
            let images = Images(fromJson: imagesJson) else {
            return nil
        }
        
        self.images = images
        
    }
    
}
