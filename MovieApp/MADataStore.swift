//
//  MADataStore.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 2/16/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MADataStore: NSObject {
    
    static let shared = MADataStore()
    
    lazy var genres: [MAGenreModel] = self.getGenresArrayFromTMDBAPIClient()
    
    var movies = [MAMovieModel]()
    
    var moviesParams = [String : String]()
    
    
    func getMediaDetailsForMovie(movie: MAMovieModel) {
        
        // Have api call for deets
        MAAPIClient.shared.getDetailsForMedia(id: movie.id, mediaFormat: .movie) { [unowned self] (errorString, detailsDict) in
            guard errorString == nil else {
                // present error
                print("Error in getMediaDetails in DS:\n" + errorString!)
                self.postUpdateDetailVCNotification()
                return
            }
            guard let detailsDict = detailsDict else {
                // present error
                print("detailsDict nil in getMediaDetails in DS:\n")
                self.postUpdateDetailVCNotification()
                return
            }
            print("Details Dict:\n\(detailsDict)")
            
            // UPdate movie model details
            self.addDetailsToMovie(detailsDict: detailsDict, movie: movie)
            
    
            // Get back drop image
            if let backdropPath = movie.backdropPath {
                MAAPIClient.shared.getImageForPathString(pathString: backdropPath, fileSize: Constants.TMDB.FileSizes.BackdropSizes[2], imageCompletionHandler: { (errorString, image) in
                    guard errorString == nil else {
                        // Probably will not report image failure as alert
                        return
                    }
                    guard let backgroundImage = image else {
                        // Again, probably will not report image failure as alert
                        return
                    }
                    
                    movie.backdropImage = backgroundImage
                    
                    self.postUpdateDetailVCNotification()
                })
            }
            
            // Todo: get cast dictionary...
        
        }
    }
    
    
    func getMediaListFromTMDBAPIClientWithParameterDict(params: [String: String], mediaFormat: MediaFormat) {
        
        let onlyPageParamDifferent = onlyPageParamIsDifferentFrom(params: params)
        let requestWithNewParameters = !onlyPageParamDifferent && params != moviesParams
        
        if mediaFormat == .movie {
            // is this new search or next page of present search

            if onlyPageParamDifferent || requestWithNewParameters {
                // don't empty movies.
                moviesParams = params
            }
            else {
                // the same parameters. do nothing
                return
            }
        }
        else {
            // TODO: check if need to clear tv show collection
        }
        
        MAAPIClient.shared.getMediaListForParameters(paramDict: params, mediaFormat: mediaFormat) { [unowned self] (errorString, responseDict) in
            
            guard errorString == nil else  {
                print("Error in data store getMediaList call")
                let userInfoDict = [Constants.ErrorKeys.Title : errorString!,
                                    Constants.ErrorKeys.Message : "Error in getMediaList call in DS"]
                self.postErrorNotificationWithUserInfoDict(userInfoDict)
                return
            }
            
            guard let responseDict = responseDict else {
                print("Error in data store getMediaList call dictionary nil")
                let userInfoDict = [Constants.ErrorKeys.Title : "Error in data store",
                                    Constants.ErrorKeys.Message : "Nil dictionary in getMediaList call in DS"]
                self.postErrorNotificationWithUserInfoDict(userInfoDict)
                return
            }
            
            // Store accordingly
            if mediaFormat == .movie {
                
                if requestWithNewParameters {
                    self.movies = []
                }
                
                let oldEndIndex = self.movies.isEmpty ? 0 : self.movies.count
                print(oldEndIndex)
                
                self.movies += self.arrayOfMovieObjectsFromResponseDicts(dict: responseDict)
                
                self.getImagesForMoviesInRange(start: oldEndIndex, end: self.movies.count)
                
                if requestWithNewParameters {
                    self.postMovieReloadDataNotification()
                }
                else {
                    // reload with the placeholder images for newly added movies
                    let x = self.movies.count
                    print("x = \(x)")
                    self.postMovieReloadNotificationForRows(Array(oldEndIndex..<self.movies.count))
                }
            }
            else {
                // TODO: add to tv show array
            }
        }
    }
    
    func getImagesForMoviesInRange(start: Int, end: Int) {
        
        for i in start..<end {
            let movie = movies[i]
            
            if let posterPath = movie.posterPath {
                
                MAAPIClient.shared.getImageForPathString(pathString: posterPath, fileSize: Constants.TMDB.FileSizes.PosterSizes[4], imageCompletionHandler: { (errorString, image) in
                    
                    guard errorString == nil else {
                        print("Error: \(errorString!)")
                        let userInfoDict = [Constants.ErrorKeys.Title : errorString!,
                                            Constants.ErrorKeys.Message : "Error getting movie image"]
                        self.postErrorNotificationWithUserInfoDict(userInfoDict)
                        return
                    }
                    
                    guard let image = image else {
                        print("nil image")
                        let userInfoDict = [Constants.ErrorKeys.Title : errorString!,
                                            Constants.ErrorKeys.Message : "Nil image"]
                        self.postErrorNotificationWithUserInfoDict(userInfoDict)
                        return
                    }
                    
                    movie.posterImage = image
                    
                    self.postMovieReloadNotificationForRow(i)
                })
            }
        }
    }
    
    func getGenresArrayFromTMDBAPIClient() -> [MAGenreModel] {
    
            MAAPIClient.shared.getGenreCategoriesFromTMDB(completionHandler: { [unowned self](errorString, responseDict) in
       
            guard errorString == nil else {
                print("Error in data store call for genres: \(errorString!)")
                let userInfoDict = [Constants.ErrorKeys.Title : errorString!,
                                    Constants.ErrorKeys.Message : "Error in GET Genres call from DS"]
                self.postErrorNotificationWithUserInfoDict(userInfoDict)
                return
            }
       
            guard let respDict = responseDict else {
                print("No response dict in data store call to get genres.")
                let userInfoDict = [Constants.ErrorKeys.Title : "What can we do about it?",
                                    Constants.ErrorKeys.Message : "No Response object in GET Genres call from DS"]
                self.postErrorNotificationWithUserInfoDict(userInfoDict)
                return
            }
       
            guard let genres = self.arrayOfGenreObjectsFromGenreResponseDict(respDict) else {
                print("Nil genres array in \(#function)")
                let userInfoDict = [Constants.ErrorKeys.Title : "Error:",
                                    Constants.ErrorKeys.Message : "Nil returned form arrayOfGenreStructFromGenreResponseDict"]
                self.postErrorNotificationWithUserInfoDict(userInfoDict)
                return
            }
       
            self.genres = genres

            self.postGenreReloadNotification()
                
            self.getGenreImagesFromTMBDApiClient()
        })
        
        
        return placeholderGenreStructs()
    }
    
    func getGenreImagesFromTMBDApiClient() {
        
        for genre in genres {

            MAAPIClient.shared.getRecentMovieImagePathForGenre(genreModel: genre, imagePathCompHandler: { (errorString, pathString) in
                
                guard errorString == nil else {
                    let userInfoDict = [Constants.ErrorKeys.Title : "Error:",
                                        Constants.ErrorKeys.Message : errorString! + " in getGenreImagesFromTMBDApiClient getMostRecentMovieImagePathForGenre call"]
                    self.postErrorNotificationWithUserInfoDict(userInfoDict)
                    return
                }
                
                guard let pathString = pathString else {
                    let userInfoDict = [Constants.ErrorKeys.Title : "Error:",
                                        Constants.ErrorKeys.Message : "nil path string in getGenreImagesFromTMBDApiClient getMostRecentMovieImagePathForGenre call"]
                    self.postErrorNotificationWithUserInfoDict(userInfoDict)
                    return
                }
                
                genre.imagePathString = pathString
                print("genre:\n\(genre)")
                
                MAAPIClient.shared.getImageForPathString(pathString: pathString, fileSize: Constants.TMDB.FileSizes.BackdropSizes[2], imageCompletionHandler: { (errorString2, image) in
                    
                    guard errorString2 == nil else {
                        let userInfoDict = [Constants.ErrorKeys.Title : "Error:",
                                            Constants.ErrorKeys.Message : errorString2! + "in getGenreImagesFromTMBDApiClient getImageForPathString call"]
                        self.postErrorNotificationWithUserInfoDict(userInfoDict)
                        return
                    }
                    
                    guard let image = image else {
                        let userInfoDict = [Constants.ErrorKeys.Title : "Error:",
                                            Constants.ErrorKeys.Message : "nil image in getGenreImagesFromTMBDApiClient getImageForPathString call"]
                        self.postErrorNotificationWithUserInfoDict(userInfoDict)
                        return
                    }
                    
                    // Success. Have image.
                    genre.genreImage = image
                    self.postGenreReloadNotification()
                })
            })
        }
    }
    
    func onlyPageParamIsDifferentFrom(params: Dictionary<String,String>) -> Bool {
        
        var pageIsDifferent = false
        var restOfDictIsSame = true
        
        for (key, value) in moviesParams {
            if key == Constants.TMDB.Parameters.Page {
                if value != params[Constants.TMDB.Parameters.Page] {
                    pageIsDifferent = true
                }
            }
            else {
                if value != params[key] {
                    restOfDictIsSame = false
                }
            }
        }
        
        return pageIsDifferent && restOfDictIsSame
    }
    
    func addDetailsToMovie(detailsDict: Dictionary<String, Any>, movie: MAMovieModel) {
        movie.plotSummary = detailsDict[Constants.TMDBDictKeys.Overview] as? String
        movie.duration = detailsDict[Constants.TMDBDictKeys.Runtime] as? Int
    }
    
    // MARK: Convert to Model Methods
    func arrayOfGenreObjectsFromGenreResponseDict(_ dict: Dictionary<String, Any>) -> [MAGenreModel]? {
        
        var arrOfGenreStructs = [MAGenreModel]()
        
        if let arrOfGenreDict = dict[Constants.TMDBDictKeys.Genres] as? Array<Dictionary<String, Any>> {
            
            for dict in arrOfGenreDict {
                let name = dict[Constants.TMDBDictKeys.Name] as? String ?? "genre name not casting to string"
                let id = dict[Constants.TMDBDictKeys.Id] as? Int ?? -2
                
                arrOfGenreStructs.append(MAGenreModel(id: id, name: name))
            }
        }
        
        return arrOfGenreStructs.count == 0 ? nil : arrOfGenreStructs
    }
    
    func placeholderGenreStructs() -> [MAGenreModel] {
        
        return Array.init(repeating: MAGenreModel.init(id: -1, name: nil), count: 10)
    }
    
    func arrayOfMovieObjectsFromResponseDicts(dict: Dictionary<String, Any>) -> [MAMovieModel]{
        
        var arrOfMovies = [MAMovieModel]()
        
        if let resultsArray = dict[Constants.TMDBDictKeys.Results] as? Array<Dictionary<String, Any>> {
            
            for movieDict in resultsArray {
                
                let movie = MAMovieModel(dictionary: movieDict)
                arrOfMovies.append(movie)
            }
        }
        else {
            print("results array in nil.")
            fatalError("What should we do with no results? in \(#function)")
        }
        
        return arrOfMovies
    }
    
    
    // MARK: - Notification Functions
    
    func postUpdateDetailVCNotification() {
        NotificationCenter.default.post(name: Constants.NotificationNames.UpdateDetailVC, object: nil)
    }
    
    func postGenreReloadNotification() {
        NotificationCenter.default.post(name: Constants.NotificationNames.GenreReload, object: nil)
    }
    
    func postMovieReloadDataNotification() {
        NotificationCenter.default.post(name: Constants.NotificationNames.MovieReload, object: nil)
    }
    
    func postMovieReloadNotificationForRow(_ row: Int) {
        let userInfo = [Constants.NotificationKeys.Row : row]
        NotificationCenter.default.post(name: Constants.NotificationNames.MovieReloadRow, object: nil , userInfo: userInfo)
    }
    
    func postMovieReloadNotificationForRows(_ rows: [Int]) {
        let userInfo = [Constants.NotificationKeys.Rows : rows]
        NotificationCenter.default.post(name: Constants.NotificationNames.MovieReloadRows, object: nil , userInfo: userInfo)
    }
    
    func postErrorNotificationWithUserInfoDict(_ dict: Dictionary<String, Any>) {
        NotificationCenter.default.post(name: Constants.NotificationNames.Error, object: nil, userInfo: dict)
    }

}

//    var genres = ["Action", "Adventure", "Animation", "Comedy", "Crime", "Documentary", "Drama", "Family", "Fantasy", "History", "Horror", "Music", "Mystery"]
