//
//  NowPlayingEntity+CoreDataProperties.swift
//  AtomicApp
//
//  Created by Omar Eduardo Gomez Padilla on 2/18/19.
//  Copyright © 2019 Omar Gómez. All rights reserved.
//
//

import Foundation
import CoreData


extension NowPlayingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NowPlayingEntity> {
        return NSFetchRequest<NowPlayingEntity>(entityName: "NowPlayingEntity")
    }

    @NSManaged public var voteCount: Int32
    @NSManaged public var id: Int64
    @NSManaged public var video: Bool
    @NSManaged public var voteAverage: Double
    @NSManaged public var title: String?
    @NSManaged public var popularity: Double
    @NSManaged public var posterPath: String?
    @NSManaged public var originalLanguage: String?
    @NSManaged public var originalTitle: String?
    @NSManaged public var genreIds: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var adult: Bool
    @NSManaged public var overview: String?
    @NSManaged public var releaseDate: String?

}
