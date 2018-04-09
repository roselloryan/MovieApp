//
//  MAMovieModel.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 2/27/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAMovieModel: NSObject {
    
    var id: Int
    var title: String?
    var releaseDate: String?
    var posterPath: String?
    var backdropPath: String?
    var voteAverage: Double? // 0-10 representing 0-5 stars in half stars
    var voteCount: Int?
    var popularity: Double?
    var posterImage: UIImage?
    
    // Detail properties
    var hasDetails = false
    var backdropImage: UIImage?
    var websiteLink: String?
    var trailerLink: String?
    var plotSummary: String?
    var director: String?
    var duration: Int?
    var cast: [String: String]?
    
    
    
    init(id: Int) {
        self.id = id
    }
    
    init(dictionary: Dictionary<String, Any>) {
        self.id = dictionary[Constants.TMDBDictKeys.Id] as! Int
        self.title = dictionary[Constants.TMDBDictKeys.Title] as? String
        self.releaseDate = dictionary[Constants.TMDBDictKeys.ReleaseDate] as? String
        self.posterPath = dictionary[Constants.TMDBDictKeys.PosterPath] as? String
        self.backdropPath = dictionary[Constants.TMDBDictKeys.BackdropPath] as? String
        self.voteAverage = dictionary[Constants.TMDBDictKeys.VoteAverage] as? Double
        self.voteCount = dictionary[Constants.TMDBDictKeys.VoteCount] as? Int
        self.popularity = dictionary[Constants.TMDBDictKeys.Popularity] as? Double
    }
    
    init(id: Int, title: String?, releaseDate: String?, posterPath: String?, backdropPath: String?, voteAverage: Double?, voteCount: Int?, popularity: Double?, posterImage: UIImage?) {
        self.id = id
        self.title = title
        self.releaseDate = releaseDate
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.popularity = popularity
        self.posterImage = posterImage
    }
    
}
