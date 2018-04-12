//
//  MAAPIClient.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 2/15/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAAPIClient: NSObject {
    
    static let shared = MAAPIClient()
    private let session = URLSession.shared
    private var configDict: Dictionary<String, Any>? = nil
    
    
    func getCreditsForMovieId( _ id: Int, getCreditsCompletionHandler: @escaping(String?, [String : Any]?) -> Void) {
        guard let url = tmdbCreditsURLForId(id: id, format: .movie) else {
            getCreditsCompletionHandler("url failed in \(#function)", nil)
            return
        }
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                getCreditsCompletionHandler("Error in \(#function):\n" + error!.localizedDescription, nil)
                return
            }
            guard let status = (response as? HTTPURLResponse)?.statusCode, status > 199 && status < 300 else  {
                let respCodeInt = (response as? HTTPURLResponse)?.statusCode
                let respString = respCodeInt == nil ? "nil" : String(describing: respCodeInt)
                getCreditsCompletionHandler("Status code: " + respString + " unsucessful in \(#function)", nil)
                return
            }
            guard let data = data else {
                getCreditsCompletionHandler("Nil data in \(#function)", nil)
                return
            }
            
            // Parse data
            self.parseJSONData(data, parseDataCompletionHandler: { (parseErrorString, anyObj) in
                guard parseErrorString == nil else {
                    getCreditsCompletionHandler("\(parseErrorString!) in \(#function)", nil)
                    return
                }
                guard let castDict = anyObj as? [String: Any] else {
                    getCreditsCompletionHandler("failed cast in \(#function)", nil)
                    return
                }
                getCreditsCompletionHandler(nil, castDict)
            })
        }
        dataTask.resume()
        
    }
    
    func getVideosForMovieId( _ id: Int, getVideoCompletionHandler: @escaping(String?, [[String : Any]]?) -> Void) {
        
        guard let url = tmdbVideosURLFromParameters(id: id, format: .movie) else {
            getVideoCompletionHandler("URL failed in \(#function)", nil)
            return
        }
        print(url.absoluteString)
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                getVideoCompletionHandler("Error in \(#function):\n" + error!.localizedDescription, nil)
                return
            }
            guard let status = (response as? HTTPURLResponse)?.statusCode, status > 199 && status < 300 else  {
                let respCodeInt = (response as? HTTPURLResponse)?.statusCode
                let respString = respCodeInt == nil ? "nil" : String(describing: respCodeInt)
                getVideoCompletionHandler("Status code: " + respString + " unsucessful in \(#function)", nil)
                return
            }
            guard let data = data else {
                getVideoCompletionHandler("Nil data in \(#function)", nil)
                return
            }
            
            self.parseJSONData(data, parseDataCompletionHandler: { (errorString, anyObj) in
                guard errorString == nil else {
                    getVideoCompletionHandler(errorString!, nil)
                    return
                }
                guard let responseDict = anyObj as? Dictionary<String, Any> else {
                    getVideoCompletionHandler("Nil Failed dict cast in \(#function)", nil)
                    return
                }
                
                guard let arrayOfVideoDicts = responseDict["results"] as? [[String : Any]] else {
                    getVideoCompletionHandler("No results array in \(#function)", nil)
                    return
                }
                
                // handle success
                getVideoCompletionHandler(nil, arrayOfVideoDicts)
            })
        }
        dataTask.resume()
    }
    
    
    func getDetailsForMedia(id: Int, mediaFormat: MediaFormat, getDetailsCompletionHandler: @escaping (String?, [String : Any]?) -> Void) {

        guard let url = tmdbDetailURLFromParameters([String : String](), format: .movie, id: id) else {
            getDetailsCompletionHandler("URL failed in \(#function)", nil)
            return
        }
        print(url.absoluteString)
        
        let task = session.dataTask(with: url) { [unowned self] (data, response, error) in
            guard error == nil else {
                getDetailsCompletionHandler("Error in \(#function):\n" + error!.localizedDescription, nil)
                return
            }
            guard let status = (response as? HTTPURLResponse)?.statusCode, status > 199 && status < 300 else  {
                let respCodeInt = (response as? HTTPURLResponse)?.statusCode
                let respString = respCodeInt == nil ? "nil" : String(describing: respCodeInt)
                getDetailsCompletionHandler("Status code: " + respString + " unsucessful in \(#function)", nil)
                return
            }
            guard let data = data else {
                getDetailsCompletionHandler("Nil data in \(#function)", nil)
                return
            }
            
            // what to do with real data?
            // convert to dictionary and pass to data store
            self.parseJSONData(data, parseDataCompletionHandler: { (errorString, anyObj) in
                guard errorString == nil else {
                    getDetailsCompletionHandler(errorString!, nil)
                    return
                }
                guard let resopnseDict = anyObj as? Dictionary<String, Any> else {
                    getDetailsCompletionHandler("Nil return from JSON parse in \(#function)", nil)
                    return
                }
                
                //Success
                getDetailsCompletionHandler(nil, resopnseDict)
            })
        }
        task.resume()
    }
    
    
    func getMediaListForParameters(paramDict: Dictionary<String, String>, mediaFormat: MediaFormat, getListCompletionHandler: @escaping (String?, Dictionary<String, Any>?) -> Void) {
    
        guard let url = tmdbDiscoverURLFromParameters(paramDict, format: mediaFormat) else {
            getListCompletionHandler("url failed in \(#function)", nil)
            return
        }
        
        let task = session.dataTask(with: url) { [unowned self] (data, response, error) in
            if error != nil {
                getListCompletionHandler(error?.localizedDescription, nil)
                return
            }
            
            guard let status = (response as? HTTPURLResponse)?.statusCode, status > 199 && status < 300 else  {
                let respCodeInt = (response as? HTTPURLResponse)?.statusCode
                let respString = respCodeInt == nil ? "nil" : String(describing: respCodeInt)
                getListCompletionHandler("Status code: " + respString + " unsucessful in \(#function)", nil)
                return
            }
            
            guard let data = data else {
                getListCompletionHandler("No data returned in \(#function).", nil)
                return
            }
            
            // Convert data to foundation object and pass to completion handler
            self.parseJSONData(data, parseDataCompletionHandler: { (parseErrorString, anyObj) in
                guard parseErrorString == nil else {
                    getListCompletionHandler(parseErrorString!, nil)
                    return
                }
                
                guard let responseDict = anyObj as? Dictionary<String, Any> else {
                    getListCompletionHandler("failed to cast dict in get mediaList parse call", nil)
                    return
                }
                
                getListCompletionHandler(nil, responseDict)
            })
        }
        task.resume()
    }
    
    
    func getGenreCategoriesFromTMDB(completionHandler: @escaping (_ errorString: String?,_ result: Dictionary<String,Any>?) -> Void)  {
        
        if configDict == nil {
            
            getTMDBConfigurationInformation(configCompletionHandler: { [unowned self] (errorString) in
            
                print("how many times?")
                
                if errorString != nil {
                    
                    completionHandler(errorString!, nil)
                }
                else {
                    
                    self.setConstantsFromConfigDictionary()
                    
                    let urlString = Constants.TMDB.GenreURL.replacingOccurrences(of: Constants.TMDB.ApiKeyPlaceholder, with: Constants.TMDB.ApiKey)
                    
                    guard let url = URL(string: urlString) else {
                        completionHandler("invalid url in GET Genres", nil)
                        return
                    }
                    
                    let task = self.session.dataTask(with: url) { [unowned self] (data, response, error) in
                        
                        if error != nil {
                            completionHandler(error?.localizedDescription, nil)
                        }
                        
                        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300 else {
                            completionHandler("Response code NOT 2xx in GET Genres.", nil)
                            return
                        }
                        
                        guard let data = data else {
                            completionHandler("No data returned in GET Genres.", nil)
                            return
                        }
                        
                        
                        self.parseJSONData(data, parseDataCompletionHandler: { (errorString, anyObj) in
                            
                            guard errorString == nil else {
                                completionHandler(errorString, nil)
                                return
                            }
                            
                            guard let resultsDict = anyObj as? Dictionary<String, Any> else {
                                completionHandler("Could not cast results to expected type in GET Genres", nil)
                                return
                            }
                            
                            // Success!
                            print("Success in genres GET")
                            completionHandler(nil, resultsDict)
                        })
                    }
                    
                    task.resume()
                }
                
            })
            
        }
        
    }
    
    func getRecentMovieImagePathForGenre(genreModel: MAGenreModel, imagePathCompHandler: @escaping (String?, String?) -> Void) {
        
        let paramDict = [Constants.TMDB.Parameters.Language: Constants.TMDB.Values.English,
                         Constants.TMDB.Parameters.IncludeAdult: Constants.TMDB.Values.False,
                         Constants.TMDB.Parameters.IncludeVideo: Constants.TMDB.Values.False,   
                         Constants.TMDB.Parameters.Page: Constants.TMDB.Values.One,
                         Constants.TMDB.Parameters.SortBy: Constants.TMDB.Values.PopularityDesc,
                         Constants.TMDB.Parameters.PrimaryReleaseYear: Constants.TMDB.CurrentYear,
                         Constants.TMDB.Parameters.WithGenres: String(genreModel.id)]
        
        guard let url = tmdbDiscoverURLFromParameters(paramDict, format: .movie) else {
            imagePathCompHandler("failed url in \(#function)", nil)
            return
        }
        
        let dataTask = session.dataTask(with: url) { [unowned self] (data, response, error) in
            
            guard error == nil else {
                imagePathCompHandler(error!.localizedDescription, nil)
                return
            }
            
            guard let status = (response as? HTTPURLResponse)?.statusCode, status > 199 && status < 300 else  {
                let respCodeInt = (response as? HTTPURLResponse)?.statusCode
                let respString = respCodeInt == nil ? "nil" : String(describing: respCodeInt)
                imagePathCompHandler("Status code: " + respString + " unsucessful in \(#function)", nil)
                return
            }
            
            guard let data = data else {
                imagePathCompHandler("Nil data in \(#function)", nil)
                return
            }
        
            self.parseJSONData(data, parseDataCompletionHandler: { (errorString, anyObj) in
                
                guard errorString == nil else {
                    imagePathCompHandler(errorString!, nil)
                    return
                }
                
                guard let dict = anyObj as? Dictionary<String, Any> else {
                    imagePathCompHandler("Failed to cast dict in \(#function)", nil)
                    return
                }
                
                guard let resultsArr = dict[Constants.TMDBDictKeys.Results] as? Array<Dictionary<String, Any>> else {
                    imagePathCompHandler("Failed to cast results array of dicts in \(#function)", nil)
                    return
                }
                
                // Create loop to find first movie with backdrop path (some paths are null from TMDB Api)
                var backdropPath: String? = nil
                var index = 0
                
                while backdropPath == nil && index < resultsArr.count  {
                    backdropPath = resultsArr[index][Constants.TMDBDictKeys.BackdropPath] as? String
                    index += 1
                    
//                    let genreStrings = MADataStore.shared.genres.flatMap { $0.imagePathString } // Changed for depricatino of flatMap
                    let genreStrings = MADataStore.shared.genres.compactMap { $0.imagePathString }
                    
                    // Prevents movies with multiple genres from being repeated in MAGenreSearchTVC
                    if let path = backdropPath {
                        if genreStrings.contains(path) {
                            backdropPath = nil
                        }
                    }
                }
                
                if backdropPath == nil {
                    imagePathCompHandler("No available backdrop image", nil)
                }
                else {
                    imagePathCompHandler(nil, backdropPath)
                }
            })
        }
        
        dataTask.resume()
    }
    
    
    func getImageForPathString(pathString: String, fileSize: String, imageCompletionHandler: @escaping (String?, UIImage?) -> Void) {
        
        guard let secureBaseUrl = Constants.TMDB.SecureBaseImageUrl else {
            imageCompletionHandler("secureBaseUrl and/or nil in \(#function)", nil)
            return
        }
    
        let urlString = secureBaseUrl + fileSize + pathString
        print("image url string:\n\(urlString)")

        guard let imageUrl = URL(string: urlString) else {
            imageCompletionHandler("url nil in \(#function)", nil)
            return
        }
        
        let dataTask = session.dataTask(with: imageUrl) { (data, response, error) in
            
            guard error == nil else {
                imageCompletionHandler(error!.localizedDescription, nil)
                return
            }
            
            guard let status = (response as? HTTPURLResponse)?.statusCode, status > 199 && status < 300 else  {
                imageCompletionHandler("Status code \((response as! HTTPURLResponse).statusCode) unsucessful in \(#function)", nil)
                return
            }
            
            guard let data = data else {
                imageCompletionHandler("Nil data in \(#function)", nil)
                return
            }

            guard let image = UIImage.init(data: data) else {
                imageCompletionHandler("Fail to init image with data in \(#function)", nil)
                return
            }
            
            // Success.
            imageCompletionHandler(nil, image)
        }
        
        dataTask.resume()
    }
    
    func getTMDBConfigurationInformation( configCompletionHandler: @escaping (_ errorString: String?) -> Void) {
        
        let urlString = Constants.TMDB.ConfigURL.replacingOccurrences(of: Constants.TMDB.ApiKeyPlaceholder, with: Constants.TMDB.ApiKey)
        
        guard let url = URL(string: urlString) else {
            configCompletionHandler("invalid url in GET Genres")
            return
        }
        
        let task = session.dataTask(with: url) { [unowned self] (data, response, error) in
            
            if error != nil {
                configCompletionHandler(error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300 else {
                configCompletionHandler("Response code NOT 2xx in GET Config.")
                return
            }
            
            guard let data = data else {
                configCompletionHandler("No data returned in GET Config.")
                return
            }
            
            
            self.parseJSONData(data, parseDataCompletionHandler: { (errorString, anyObj) in
                
                guard errorString == nil else {
                    configCompletionHandler(errorString)
                    return
                }
                
                guard let resultsDict = anyObj as? Dictionary<String, Any> else {
                    configCompletionHandler("Could not cast results to expected type in GET config")
                    return
                }
                
                // Success!
                self.configDict = resultsDict
                
                configCompletionHandler(nil)
            })
        }
        
        task.resume()
    }
    
    // MARK: - Helper Methods (Should these even be in here?)
    private func setConstantsFromConfigDictionary() {
        
        if let config = configDict {
            
            guard let imagesDict = config[Constants.TMDBDictKeys.Images] as? Dictionary<String, Any> else {
                print("config dict not casting in \(#function)")
                return
            }
            guard let secureBaseUrl = imagesDict[Constants.TMDBDictKeys.SecureBaseUrl] as? String else {
                print("secureBaseUrl not casting in \(#function)")
                return
            }
            guard let backdropSizesArray = imagesDict[Constants.TMDBDictKeys.BackdropSizes] as? Array<String> else {
                print("backdropSizes Array not casting in \(#function)")
                return
            }
            guard let posterSizesArray = imagesDict[Constants.TMDBDictKeys.PosterSizes] as? Array<String> else {
                print("posterSizes Array not casting in \(#function)")
                return
            }
            guard let logoSizesArray = imagesDict[Constants.TMDBDictKeys.LogoSizes] as? Array<String> else {
                print("logoSizes Array not casting in \(#function)")
                return
            }
            
            Constants.TMDB.SecureBaseImageUrl = secureBaseUrl
            
            Constants.TMDB.FileSizes.BackdropSizes = backdropSizesArray
            Constants.TMDB.FileSizes.PosterSizes = posterSizesArray
            Constants.TMDB.FileSizes.LogoSizes = logoSizesArray
        }
    }
        
    private func parseJSONData(_ data: Data, parseDataCompletionHandler: @escaping (_: String?, _: AnyObject?) -> Void) {
        
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            
            parseDataCompletionHandler(nil, parsedResult)
        } catch {
            
            parseDataCompletionHandler("Failed to parse data.", nil)
        }
    }
    
    private func tmdbCreditsURLForId(id: Int, format: MediaFormat) -> URL? {
        
        var params = [String : String]()
        params[Constants.TMDB.Parameters.ApiKey] =  Constants.TMDB.ApiKey
        
        var components = URLComponents()
        components.scheme = Constants.TMDB.Scheme
        components.host = Constants.TMDB.Host
        components.path = format == MediaFormat.movie ? Constants.TMDB.MoviePath : Constants.TMDB.TVPath
        components.path += String(id)
        components.path += "/credits"
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url
    }
    
    private func tmdbVideosURLFromParameters(id: Int, format: MediaFormat) -> URL? {
        
        var params = [String : String]()
        params[Constants.TMDB.Parameters.ApiKey] =  Constants.TMDB.ApiKey
        
        var components = URLComponents()
        components.scheme = Constants.TMDB.Scheme
        components.host = Constants.TMDB.Host
        components.path = format == MediaFormat.movie ? Constants.TMDB.MoviePath : Constants.TMDB.TVPath
        components.path += String(id)
        components.path += "/videos"
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url
    }

    private func tmdbDetailURLFromParameters(_ parameters: [String: String], format: MediaFormat, id: Int) -> URL? {
        
        var params = parameters
        params[Constants.TMDB.Parameters.ApiKey] =  Constants.TMDB.ApiKey
        
        var components = URLComponents()
        components.scheme = Constants.TMDB.Scheme
        components.host = Constants.TMDB.Host
        components.path = format == MediaFormat.movie ? Constants.TMDB.MoviePath : Constants.TMDB.TVPath
        components.path += String(id)
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url
    }
    
    private func tmdbDiscoverURLFromParameters(_ parameters: [String: String], format: MediaFormat) -> URL? {
        
        var params = parameters
        params[Constants.TMDB.Parameters.ApiKey] =  Constants.TMDB.ApiKey
        
        var components = URLComponents()
        components.scheme = Constants.TMDB.Scheme
        components.host = Constants.TMDB.Host
        components.path = format == MediaFormat.movie ? Constants.TMDB.DiscoverMoviePath : Constants.TMDB.DiscoverTVPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url
    }
}
