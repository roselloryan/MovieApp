//
//  MAConstants.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 2/15/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import Foundation
import CoreGraphics

struct Constants {
    
    struct TMDB {
        static let ApiKey = "734c0fa0f34717b52dfe59d8f7dab2d9"
        
        static let ApiKeyPlaceholder = "<API_KEY>"
        static let GenreIdPlaceholder = "<GENRE_ID>"
        static let YearPlaceholder = "<YEAR>"
        
        static let Scheme = "https"
        static let Host = "api.themoviedb.org"
        static let DiscoverMoviePath = "/3/discover/movie"
        static let DiscoverTVPath = "/3/discover/tv"
        static let ConfigurationPath = "/3/configuration"
        
        static let GenreURL = "https://api.themoviedb.org/3/genre/movie/list?api_key=\(Constants.TMDB.ApiKey)&language=en-US"
        static let ConfigURL = "https://api.themoviedb.org/3/configuration?api_key=\(Constants.TMDB.ApiKey)"
        static let GenreMovieURL = "https://api.themoviedb.org/3/discover/movie?api_key=\(Constants.TMDB.ApiKey)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&primary_release_year=\(Constants.TMDB.YearPlaceholder)&with_genres=\(Constants.TMDB.GenreIdPlaceholder)"
        
        struct Parameters {
            static let ApiKey = "api_key"
            static let Language = "language"
            static let SortBy = "sort_by"
            static let IncludeAdult = "include_adult"
            static let IncludeVideo = "include_video"
            static let PrimaryReleaseYear = "primary_release_year"
            static let WithGenres = "with_genres"
            static let Page = "page"
        }
        
        struct Values {
            static let English = "en-US"
            static let PopularityDesc = "popularity.desc"
            static let False = "false"
            static let One = "1"
        }
        
        struct FileSizes {
            static var BackdropSizes = [String]()  // Current backdrop_sizes: ["w300","w780","w1280","original"]
            static var PosterSizes = [String]() // Current poster_sizes: ["w92","w154","w185","w342","w500","w780","original"]
            static var LogoSizes = [String]()   //  Current logo_sizes: ["w45","w92","w154","w185","w300","w500","original"]
        }
        
        // Image related
        static var SecureBaseImageUrl: String? = nil
        static var BackdropSize: String? = nil
        
        // Miscelaneous
        static let CurrentYear = String(Calendar.current.component(.year, from: Date()))
        
        static func isoDateStringForYear(_ year: Int) -> String {
            return "\(year)-01-01"
        }
    }
    

    
    
    struct TMDBDictKeys {
        static let Id = "id"
        static let Genres = "genres"
        static let Name = "name"
        static let Images = "images"
        static let Results = "results"
        
        static let Title = "title"
        static let VoteCount = "vote_count"
        static let VoteAverage = "vote_average"
        static let ReleaseDate = "release_date"
        static let Popularity = "popularity"
        
        static let PosterPath = "poster_path"
        static let SecureBaseUrl = "secure_base_url"
        static let BackdropPath = "backdrop_path"
        static let BackdropSizes = "backdrop_sizes"
        static let PosterSizes = "poster_sizes"
        static let LogoSizes = "logo_sizes"
        
    }
    
    struct NotificationNames {
        static let GenreReload = Notification.Name("GenreReloadNotification")
        static let MovieReload = Notification.Name("MovieReloadNotification")
        static let MovieReloadRow = Notification.Name("MovieReloadRowNotification")
        static let Error = Notification.Name("errorNotification")
    }
    
    struct ErrorKeys {
        static let Title = "title"
        static let Message = "message"
    }
    
    struct NotificationKeys {
        static let Row = "row"
    }
    
    struct ImageNames {
        static let Placeholder = "placeholder"
    }
    
    
    struct Dimensions {
        static var TableViewCellHeight: CGFloat? = nil
        
        static var CollectionViewMovieCellInset: CGFloat = 8.0
        static var CollectionViewMovieCellWidth: CGFloat? = nil
        static var CollectionViewMovieCellHeight: CGFloat? = nil
        static var CollectionViewMovieCellSize = CGSize.init(width: Constants.Dimensions.CollectionViewMovieCellWidth ?? 20.0, height: Constants.Dimensions.CollectionViewMovieCellHeight ?? 20.0)
        
        
        static func calculateDimensionsFromDeviceFrame(_ frame: CGRect) {
            let h = max(frame.height, frame.width)
            let w = min(frame.height, frame.width)
            
            Constants.Dimensions.TableViewCellHeight = h / 4
            
            Constants.Dimensions.CollectionViewMovieCellWidth = (w - 4.0 * Constants.Dimensions.CollectionViewMovieCellInset) / 3.0
            Constants.Dimensions.CollectionViewMovieCellHeight = Constants.Dimensions.CollectionViewMovieCellWidth! * 1.51
            
        }
        
        // TODO: Add collection view edge insets
    }
    
    struct Identifiers {
        static let MovieCollectionViewCell = "MovieCollectionViewCell"
        static let GenreTableViewCell = "GenreCell"
        static let MovieCollectionViewSegue = "MovieCollectionViewSegue"
        static let MovieFiltersSegue = "MovieFilterSegue"
        
        static let MainStoryboardName = "Main"
        static let FilterTableVC = "FilterTableViewController"
    }
    
}
