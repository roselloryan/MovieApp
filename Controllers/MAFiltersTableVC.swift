//
//  MAFiltersTableVCTableViewController.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 3/2/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAFiltersTableVC: UITableViewController {
    
    var sortBySelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.Filter.MovieSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO:  set sort by and filter data sources
        switch section {
        case 0:
            return sortBySelected ? Constants.Filter.SortByEnums.count : 1
        case 1:
            return 1
        default:
            fatalError("unrecognized section in FilterTVC")
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.FilterTableViewCell, for: indexPath) as! MAFilterTableViewCell

        switch indexPath.section {
        case 0:
            if !sortBySelected {
                cell.sortBy = currentSortByFromParentParamDict() ?? Constants.Filter.SortByEnums.first!
            }
            else {
                let sortBy = Constants.Filter.SortByEnums[indexPath.row]
                
                cell.sortBy = sortBy
                
                cell.accessoryType = currentSortByFromParentParamDict() == sortBy ? .checkmark : .none
            }
        case 1:
            print("Need a filter cell")
        default:
            fatalError("too many sections in filterTVC \(#function)\n\(#line)")
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.Filter.MovieSections[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("section: \(indexPath.section) row: \(indexPath.row)")
        
        if indexPath.section == 0 {
            if sortBySelected {
                setParentMovieCollectionViewSortByParameter(Constants.Filter.SortByEnums[indexPath.row])
            }
            sortBySelected = !sortBySelected
            tableView.reloadSections([0], with: .automatic)
            
        }
        // 1. Set new params dict
        // 2. Call data store for new results EACH time filter adjusted. Like amazon.
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.backgroundColor = .clear
        headerView.textLabel?.textColor = .white
        headerView.detailTextLabel?.textColor = .white
    }


    func setParentMovieCollectionViewSortByParameter(_ sortByParam: SortBy) {
        let parentMovieCollectionVC = (parent as! MAMoviesVC)
        parentMovieCollectionVC.filterParamDict[Constants.TMDB.Parameters.SortBy] = dictValueForSortBy(sortByParam)
        parentMovieCollectionVC.askDataStoreToCallForMoviesIfEmptyOrParamsChanged()
    }
    
    func currentSortByFromParentParamDict() -> SortBy? {

        let parentMovieCollectionVC = (parent as! MAMoviesVC)

        guard let paramSortString = parentMovieCollectionVC.filterParamDict[Constants.TMDB.Parameters.SortBy] else {
            fatalError("No sortBy in default dictionary \(#function)")
        }
        print(paramSortString)
        return sortByForDictValue(paramSortString)
    }
    
    func dictValueForSortBy(_ sortBy: SortBy) -> String {
        switch sortBy {
        case .popularityAsc:
            return Constants.TMDB.Values.PopularityAsc
        case .popularityDesc:
            return Constants.TMDB.Values.PopularityDesc
        case .averageVoteAsc:
            return Constants.TMDB.Values.AverageVoteAsc
        case .averageVoteDesc:
            return Constants.TMDB.Values.AverageVoteDesc
        case .titleAsc:
            return Constants.TMDB.Values.OriginalTitleAsc
        case .titleDesc:
            return Constants.TMDB.Values.OriginalTitleDesc
        }
    }
    
    func sortByForDictValue(_ value: String) -> SortBy {
        switch value {
        case Constants.TMDB.Values.PopularityAsc:
            return .popularityAsc
        case Constants.TMDB.Values.PopularityDesc:
            return .popularityDesc
        case Constants.TMDB.Values.AverageVoteAsc:
            return .averageVoteAsc
        case Constants.TMDB.Values.AverageVoteDesc:
            return .averageVoteDesc
        case Constants.TMDB.Values.OriginalTitleAsc:
            return .titleAsc
        case Constants.TMDB.Values.OriginalTitleDesc:
            return .titleDesc
        default:
            fatalError("getting unknown dict sort value in \(#function)")
        }
    }

}
