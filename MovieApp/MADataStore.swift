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
    var moviesParams = Dictionary<String, String>()
    
    
    func getMediaListFromTMDBAPIClientWithParameterDict(params: [String: String], mediaFormat: MediaFormat) {
        
        if mediaFormat == .movie {
            if moviesParams != params || !moviesParams.isEmpty {
                movies.removeAll()
                moviesParams = params
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
                self.movies += self.arrayOfMovieObjectsFromResponseDicts(dict: responseDict)
                self.getImagesForMovies()
                self.postMovieReloadDataNotification()
            }
            else {
                // TODO: add to tv show array
            }
        }
    }
    
    func getImagesForMovies() {
        
        for (index, movie) in movies.enumerated() {
            
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
                    
                    
                    self.postMovieReloadNotificationForRow(index)
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
    
    func postErrorNotificationWithUserInfoDict(_ dict: Dictionary<String, Any>) {
        NotificationCenter.default.post(name: Constants.NotificationNames.Error, object: nil, userInfo: dict)
    }

}

//    var genres = ["Action", "Adventure", "Animation", "Comedy", "Crime", "Documentary", "Drama", "Family", "Fantasy", "History", "Horror", "Music", "Mystery"]
