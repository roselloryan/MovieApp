//
//  FIlters.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 3/6/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import Foundation

struct Filter {
    
    var filterType: FilterType
    var dictParamString: String {
        get {
            return dictParamStringFromFilterType(filterType)
        }
    }
    var cellLabelTextString: String {
        get {
            return cellLabelTextStringFromFilterType(filterType)
        }
    }
    
    private func dictParamStringFromFilterType(_ filterType: FilterType) -> String {
        switch filterType {
        case .releaseYear:
            return Constants.TMDB.Parameters.PrimaryReleaseYear
        case .olderThanYear:
            return Constants.TMDB.Parameters.PrimaryReleaseDateGreaterThan
        case .newerThanYear:
            return Constants.TMDB.Parameters.PrimaryReleaseDateLessThan
        case .language:
            return Constants.TMDB.Parameters.Language
        case .avgVoteGreaterThan:
            return Constants.TMDB.Parameters.VoteAverageGreaterThan
        }
    }
    
    private func cellLabelTextStringFromFilterType(_ filterType: FilterType) -> String {
        switch filterType {
        case .releaseYear:
            return "Release Year:"
        case .olderThanYear:
            return "Released After:"
        case .newerThanYear:
            return "Released Before:"
        case .language:
            return "Language:"
        case .avgVoteGreaterThan:
            return "Ratings:"
        }
    }
}
