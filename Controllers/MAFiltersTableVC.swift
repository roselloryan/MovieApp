//
//  MAFiltersTableVCTableViewController.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 3/2/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit


enum FilterSections: Int {
    case sortBy = 0
    case filter
}

class MAFiltersTableVC: UITableViewController {
    
    var languages = Constants.Filter.Languages
    var sortByEnums = Constants.Filter.SortByEnums
    var filterTypes = Constants.Filter.FilterTypes
    var ratings = Constants.Filter.Ratings
    
    var sortBySelected = false
    var sortRowSelected = 0
    
    var languageFilterSelected = false
    var languageRowSelected = 1
    var languageSelected = Language.english
    
    var ratingsFilterSelected = false
    var ratingFilterSelected = Rating.zeroStars
    
    var releaseYearFilterSelected = false
    

    
    // MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.layer.borderWidth = 0.25
        tableView.layer.borderColor = UIColor.white.cgColor
        
        tableView.rowHeight = 40
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

        switch section {
        
        case FilterSections.sortBy.rawValue:
            return sortBySelected ? sortByEnums.count : 1
        
        case FilterSections.filter.rawValue:
            let total = filterTypes.count
            
            let languageCellsCount = languageFilterSelected ? languages.count : 0
            let ratingsCellsCount = ratingsFilterSelected ? ratings.count : 0
            
            
            return total + languageCellsCount + ratingsCellsCount
        default:
            fatalError("unrecognized section in FilterTVC")
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.FilterTableViewCell, for: indexPath) as! MAFilterTableViewCell

        switch indexPath.section {
        case 0:
            configureSortByForCell(cell, atIndextPath: indexPath)
        case 1:
            // TODO: All this should come out of cellForRowAt
            if indexPath.row == 0 {
                cell.textLabel?.text = "Language:"
                cell.cellState = .pointingDown
            }
            if languageFilterSelected {
                if indexPath.row > 0 && indexPath.row < languages.count + 1 {
                cell.language = languages[indexPath.row - 1]
                cell.cellState = cell.language == languageSelected ? .selected : .unselected
                }
                if indexPath.row == languages.count + 1 {
                    cell.textLabel?.text = "Ratings:"
                    cell.cellState = .pointingDown
                }
                else if indexPath.row > languages.count + 1 && indexPath.row <= languages.count + 1 + ratings.count {
                    
                    switch indexPath.row {
                    case languages.count + 2:
                        cell.rating = .zeroStars
                    case languages.count + 3:
                        cell.rating = .oneStar
                    case languages.count + 4:
                        cell.rating = .twoStars
                    case languages.count + 5:
                        cell.rating = .threeStars
                    case languages.count + 6:
                        cell.rating = .fourStars
                    case languages.count + 7:
                        cell.rating = .fiveStars
                    default:
                        fatalError("more ratings cells than expected")
                    }
            
                    cell.cellState = cell.rating! == ratingFilterSelected ? .selected : .unselected
                }
            }
            else if !languageFilterSelected {
                if indexPath.row == 1 {
                    cell.textLabel?.text = "Ratings:"
                    cell.cellState = .pointingDown
                }
                if indexPath.row > 1 && indexPath.row < 8 {
                    cell.rating = .zeroStars
                    cell.cellState = .unselected
                    switch indexPath.row {
                    case 2:
                        cell.rating = .zeroStars
                    case 3:
                        cell.rating = .oneStar
                    case 4:
                        cell.rating = .twoStars
                    case 5:
                        cell.rating = .threeStars
                    case 6:
                        cell.rating = .fourStars
                    case 7:
                        cell.rating = .fiveStars
                    default:
                        fatalError("more ratings cells than expected")
                    }
                    
                    cell.cellState = cell.rating! == ratingFilterSelected ? .selected : .unselected
                }
            }
        
        default:
            fatalError("too many sections in filterTVC \(#function)\n\(#line)")
        }

        return cell
    }
    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.Filter.MovieSections[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor.black
        headerView.textLabel?.font = UIFont.systemFont(ofSize: Constants.FontInfo.FilterCellFontSize, weight: .regular)
        headerView.textLabel?.textColor = .lightText
        headerView.detailTextLabel?.textColor = .lightText
        }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("section: \(indexPath.section) row: \(indexPath.row)")
        
        let section = FilterSections(rawValue: indexPath.section)
        
        if section == .sortBy {
            updateSortByCellUIWithSelctionAtIndexPath(indexPath)
        
            if sortBySelected {
                setParentMovieCollectionViewSortByParameter(sortByEnums[indexPath.row])
            }
            else {
                sortBySelected = !sortBySelected
                insertAllSortByCellsExceptAtIndexPath(indexPath)
            }
        }
        else if section == .filter {
            
            if isIndexPathOfLanguageTitleCell(indexPath) {
                updateForLanguageTitleCellSelected()
            }
            else if languageFilterSelected {
                
                if isIndexPathOfLanguageCell(indexPath) {
                    updateForLanguageCellSelected()
                    setParentMovieCollectionViewLanguageParameter()
                }
                else if indexPath.row == languages.count + 1 {
                    updateForRatingsTitleCellTapped()
                }
                else {
                    updateForRatingsCellTapped(languageFilterSelected: languageFilterSelected)
                    setParentMovieCollectionViewRatingsParameter()
                }
            }
            else if !languageFilterSelected {
                if indexPath.row == 1 {
                    updateForRatingsTitleCellTapped()
                }
                else {
                    updateForRatingsCellTapped(languageFilterSelected: languageFilterSelected)
                    setParentMovieCollectionViewRatingsParameter()
                }
            }
        }
       
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func updateForRatingsCellTapped(languageFilterSelected: Bool) {
        let newlySelectedRatingsCell = (tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! MAFilterTableViewCell)
    
        if newlySelectedRatingsCell.rating != ratingFilterSelected {
            
            let languageCellsOffset = languageFilterSelected ? languages.count : 0
            
            for i in (languageCellsOffset + 2)..<(languageCellsOffset + 2) + ratings.count {
                let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1)) as! MAFilterTableViewCell
                if cell.cellState == .selected {
                    cell.cellState = .unselected
                }
            }
            
            newlySelectedRatingsCell.cellState = .selected
            ratingFilterSelected = newlySelectedRatingsCell.rating!
        }
    }
    
    func isIndexPathOfLanguageTitleCell(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }
    
    func updateForLanguageCellSelected() {
        let oldLanguageCell = currentlySelectedLanguageCell()
        let newLanguageCell = (tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! MAFilterTableViewCell)
        
        if newLanguageCell.language != oldLanguageCell.language {
            oldLanguageCell.cellState = .unselected
            newLanguageCell.cellState = .selected
            
            languageSelected = newLanguageCell.language!
            languageRowSelected = tableView.indexPathForSelectedRow!.row
        }
    }
    func updateForLanguageTitleCellSelected() {
        
        let cell = (tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! MAFilterTableViewCell)
        
        cell.cellState = languageFilterSelected ? .pointingDown : .pointingUp
        
        languageFilterSelected = !languageFilterSelected
        
        if languageFilterSelected {
            insertLanguagesCells()
        }
        else {
            deleteLanguagesCells()
        }
    }
    
    func currentlySelectedLanguageCell() -> MAFilterTableViewCell {
        return tableView.cellForRow(at: IndexPath(row: languageRowSelected, section: 1)) as! MAFilterTableViewCell
    }
    
    func isIndexPathOfLanguageCell(_ indexPath: IndexPath) -> Bool {
        
        return indexPath.row > 0 && indexPath.row <= languages.count
    }
    
    func scrollToLastCell() {
        var total = filterTypes.count - 1
        
        let languageCellsCount = languageFilterSelected ? languages.count : 0
        let ratingsCellsCount = ratingsFilterSelected ? ratings.count : 0
        
        total = total + languageCellsCount + ratingsCellsCount
        
        tableView.scrollToRow(at: IndexPath(row: total, section: 1), at: .top, animated: true)
    }
    
    func updateForRatingsTitleCellTapped() {
        
        let cell = (tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! MAFilterTableViewCell)
        cell.cellState = cell.cellState == .pointingDown ? .pointingUp : .pointingDown
        ratingsFilterSelected = !ratingsFilterSelected
        
        if ratingsFilterSelected {
            insertRatingsCells()
        }
        else {
            deleteRatingsCells()
        }
    }
    
    func insertRatingsCells() {
        let offset = languageFilterSelected ? languages.count + 2 : 2 // Two is for Language: cell and Rating: cell
        var indexPathsToInsert = [IndexPath]()
        
        for i in 0..<6 {
            indexPathsToInsert.append(IndexPath.init(row: i + offset, section: FilterSections.filter.rawValue))
        }
        
        // TODO: clean this up in to single method
        CATransaction.begin()
        tableView.beginUpdates()
        CATransaction.setCompletionBlock { [unowned self] in
            // Code to be executed upon completion
            self.scrollToLastCell()
        }
        tableView.insertRows(at: indexPathsToInsert, with: .automatic)
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    func deleteRatingsCells() {
        let offset = languageFilterSelected ? languages.count + 2 : 2 // Two is for Language: cell and Rating: cell
        var indexPathsToInsert = [IndexPath]()
        
        for i in 0..<6 {
            indexPathsToInsert.append(IndexPath.init(row: i + offset, section: FilterSections.filter.rawValue))
        }
        tableView.deleteRows(at: indexPathsToInsert, with: .automatic)
    }
    
    func insertLanguagesCells() {
        var indexPathsToInsert = [IndexPath]()
        
        for i in 0..<Constants.Filter.Languages.count {
            indexPathsToInsert.append(IndexPath(row: i + 1, section: 1))
        }
        
        // TODO: clean this up in to single method
        CATransaction.begin()
        tableView.beginUpdates()
        CATransaction.setCompletionBlock { [unowned self] in
            // Code to be executed upon completion
            self.scrollToLastCell()
        }
        tableView.insertRows(at: indexPathsToInsert, with: .automatic)
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    func deleteLanguagesCells() {
        var indexPathsToDelete = [IndexPath]()
        
        for i in 0..<Constants.Filter.Languages.count {
            indexPathsToDelete.append(IndexPath(row: i + 1, section: 1))
        }
        
        tableView.deleteRows(at: indexPathsToDelete, with: .automatic)
    }
    
    // MARK: - Custom Table View methods
    
    func updateSortByCellUIWithSelctionAtIndexPath(_ indexPath: IndexPath) {
        
        let oldSelectedCell = (tableView.cellForRow(at: IndexPath(row: sortRowSelected, section: indexPath.section)) as! MAFilterTableViewCell)
        let newSelectedCell = (tableView.cellForRow(at: indexPath) as! MAFilterTableViewCell)
        
        oldSelectedCell.cellState = .unselected
        newSelectedCell.cellState = .selected
        
        sortRowSelected = indexPath.row
    }
    
    
    func configureSortByForCell(_ cell: MAFilterTableViewCell, atIndextPath indexPath: IndexPath) {
        if !sortBySelected {
            cell.sortBy = currentSortByFromParentParamDict() ?? sortByEnums.first!
            cell.cellState = .pointingDown
        }
        else {
            let sortBy = sortByEnums[indexPath.row]
            cell.sortBy = sortBy
            cell.cellState = sortBy == currentSortByFromParentParamDict() ? .selected : .unselected
        }
    }
    
    func insertAllSortByCellsExceptAtIndexPath(_ indexPath: IndexPath) {
        var indexPathsToInsert = [IndexPath]()
        
        for i in 0..<sortByEnums.count {
            if (tableView.cellForRow(at: indexPath) as! MAFilterTableViewCell).sortBy != sortByEnums[i] {
                indexPathsToInsert.append(IndexPath(row: i, section: indexPath.section))
            }
        }
        tableView.insertRows(at: indexPathsToInsert, with: .automatic)
    }
    
    func setParentMovieCollectionViewRatingsParameter() {
        let parentMovieCollectionVC = (parent as! MAMoviesVC)
        parentMovieCollectionVC.filterParamDict[Constants.TMDB.Parameters.VoteAverageGreaterThan] = String(ratingFilterSelected.rawValue)
        parentMovieCollectionVC.filterParamDict[Constants.TMDB.Parameters.Page] = Constants.TMDB.Values.One
        parentMovieCollectionVC.collectionView.setContentOffset(CGPoint.zero, animated: false)
        parentMovieCollectionVC.askDataStoreToCallForMoviesIfEmptyOrParamsChanged()
    }

    func setParentMovieCollectionViewLanguageParameter() {
        let parentMovieCollectionVC = (parent as! MAMoviesVC)
        parentMovieCollectionVC.filterParamDict[Constants.TMDB.Parameters.OriginalLanguage] = languageCodeForSelectedLanguage()
        parentMovieCollectionVC.filterParamDict[Constants.TMDB.Parameters.Page] = Constants.TMDB.Values.One
        parentMovieCollectionVC.collectionView.setContentOffset(CGPoint.zero, animated: false)
        parentMovieCollectionVC.askDataStoreToCallForMoviesIfEmptyOrParamsChanged()
    }

    func setParentMovieCollectionViewSortByParameter(_ sortByParam: SortBy) {
        let parentMovieCollectionVC = (parent as! MAMoviesVC)
        parentMovieCollectionVC.filterParamDict[Constants.TMDB.Parameters.SortBy] = dictValueForSortBy(sortByParam)
        parentMovieCollectionVC.filterParamDict[Constants.TMDB.Parameters.Page] = Constants.TMDB.Values.One
        parentMovieCollectionVC.collectionView.setContentOffset(CGPoint.zero, animated: false)
        parentMovieCollectionVC.askDataStoreToCallForMoviesIfEmptyOrParamsChanged()
    }
    
    func currentSortByFromParentParamDict() -> SortBy? {
        let parentMovieCollectionVC = (parent as! MAMoviesVC)
        guard let paramSortString = parentMovieCollectionVC.filterParamDict[Constants.TMDB.Parameters.SortBy] else {
            fatalError("No sortBy in default dictionary \(#function)")
        }
        
        return sortByForDictValue(paramSortString)
    }
    
    // MARK: - Probably shouldn't be in here
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
    
    func languageCodeForSelectedLanguage() -> String {
        switch languageSelected {
        case .english:
            return Constants.LanguageCodes.English
        case .spanish:
            return Constants.LanguageCodes.Spanish
        }
    }

}
