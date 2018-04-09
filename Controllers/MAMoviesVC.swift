//
//  MAMoviesVC.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 3/2/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAMoviesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var genre: MAGenreModel!
    lazy var filterParamDict: Dictionary<String, String> = defaultFilterParametersDictionary()
    
    var resultsPage = 1
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filtersContainerView: UIView!
    
    var lastSelectedIndexPath: IndexPath?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        addRightBarButtonsToNavBar()
        disableFilterTableViewUI(animated: false)
        
        askDataStoreToCallForMoviesIfEmptyOrParamsChanged()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addNotificationObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeNotificationObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("I'm melting... i'm melting...")
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MADataStore.shared.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifiers.MovieCollectionViewCell, for: indexPath) as! MAMovieCollectionViewCell
        
        let movie = MADataStore.shared.movies[indexPath.row]
        cell.movie = movie
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate

    
    
    // MARK: - Movie Data Store Related Methods
    
    func askDataStoreToCallForMoviesIfEmptyOrParamsChanged() {
        // TODO: called twice when language changes second time 😫
        
        if filterParamDict != MADataStore.shared.moviesParams {
            dimScreenWithActivitySpinner()
            
            MADataStore.shared.getMediaListFromTMDBAPIClientWithParameterDict(params: filterParamDict , mediaFormat: .movie)
        }
    }
    
    func onlyPageParamIsDifferentFrom(params: Dictionary<String,String>) -> Bool {
        
        var pageIsDifferent = false
        var restOfDictIsSame = true
        
        for (key, value) in MADataStore.shared.moviesParams {
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
    
    func defaultFilterParametersDictionary() -> Dictionary<String, String> {
        
        let paramDict = [Constants.TMDB.Parameters.Language: Constants.TMDB.Values.English,
                         Constants.TMDB.Parameters.IncludeAdult: Constants.TMDB.Values.False,
                         Constants.TMDB.Parameters.IncludeVideo: Constants.TMDB.Values.False,
                         Constants.TMDB.Parameters.Page: Constants.TMDB.Values.One,
                         Constants.TMDB.Parameters.SortBy: Constants.TMDB.Values.PopularityDesc,
                         Constants.TMDB.Parameters.PrimaryReleaseDateLessThan: Constants.TMDB.CurrentDate,
                         Constants.TMDB.Parameters.OriginalLanguage: Constants.LanguageCodes.English,
                         Constants.TMDB.Parameters.WithGenres: String(genre.id)]
        
        return paramDict
    }
    
    // MARK: - Notification Methods
    func addObserverForDataReload() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReloadData), name: Constants.NotificationNames.MovieReload, object: nil)
    }
    
    func addObserverForReloadRows() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRows(_:)), name: Constants.NotificationNames.MovieReloadRows, object: nil)
    }
    
    func addObserverForReloadCellAtRow() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCellAtIndexPathFromNotification(_:)), name: Constants.NotificationNames.MovieReloadRow, object: nil)
    }
    
    func addObserverForErrors() {
        NotificationCenter.default.addObserver(self, selector: #selector(postErrorFromNotification(_:)), name: Constants.NotificationNames.Error, object: nil)
    }
    
    func removeObserverForError() {
        NotificationCenter.default.removeObserver(self, name: Constants.NotificationNames.Error, object: nil)
    }
    
    func removeObserverForDataReload() {
        NotificationCenter.default.removeObserver(self, name: Constants.NotificationNames.MovieReload, object: nil)
    }
    
    func removeObserverForReloadCellAtRow() {
        NotificationCenter.default.removeObserver(self, name: Constants.NotificationNames.MovieReloadRow, object: nil)
    }
    
    func removeObserverForReloadRows() {
        NotificationCenter.default.removeObserver(self, name: Constants.NotificationNames.MovieReloadRows, object: nil)
    }
    
    
    
    func addNotificationObservers() {
        addObserverForDataReload()
        addObserverForReloadCellAtRow()
        addObserverForReloadRows()
        addObserverForErrors()
    }
    
    func removeNotificationObservers() {
        removeObserverForDataReload()
        removeObserverForReloadCellAtRow()
        removeObserverForReloadRows()
        removeObserverForError()
    }
    
    @objc func notificationReloadData() {
        DispatchQueue.main.async { [unowned self] in
            self.undimScreenAndRemoveActivitySpinner()
            self.collectionView?.reloadData()
        }
    }
    
    @objc func reloadRows(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            if let rows = userInfo[Constants.NotificationKeys.Rows] as? [Int] {
                
                let indexPaths = rows.map {IndexPath(row: $0, section: 0)}
                
                print(indexPaths)
                DispatchQueue.main.async { [unowned self] in
                    self.undimScreenAndRemoveActivitySpinner()
                    self.collectionView?.insertItems(at: indexPaths)
                }
            }
        }
    }
    
    @objc func reloadCellAtIndexPathFromNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            if let row = userInfo[Constants.NotificationKeys.Row] as? Int {
                
                DispatchQueue.main.async { [unowned self] in
                    self.undimScreenAndRemoveActivitySpinner()
                    
                    let indexPath = IndexPath(row: row, section: 0)
                    
                    if self.collectionView.cellForItem(at: indexPath) != nil {
                        self.collectionView?.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    @objc func postErrorFromNotification(_ notification: Notification) {
        
        print("In postErrorFromNotification.\nNotification: \(notification)")
        
        if let userInfo = notification.userInfo as? Dictionary<String, Any> {
            
            let title = userInfo[Constants.ErrorKeys.Title] as? String ?? ""
            let message = userInfo[Constants.ErrorKeys.Message] as? String ?? ""
            
            DispatchQueue.main.async { [unowned self] in
                self.presentAlertWith(title: title, message: message)
            }
        }
        else {
            print("No userInfo dict with error notification in postErrorFromNotification(:) in DS.")
            
            DispatchQueue.main.async { [unowned self] in
                self.presentAlertWith(title: "Error", message: "no userInfo with notification in GenreSearchTVC")
            }
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.

        if segue.identifier == Constants.Identifiers.DetailMovieSegue {
            let destinationVC = segue.destination as! MADetailedMovieVC
            let movie = (collectionView.cellForItem(at: collectionView.indexPathsForSelectedItems!.first!) as! MAMovieCollectionViewCell).movie
            destinationVC.movie = movie!
        }
    }
    
    // MARK: - Navigation bar methods
    func addRightBarButtonsToNavBar() {
        let rightSearchBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        let rightFilterBarButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterButtonTapped))
        
        navigationItem.setRightBarButtonItems([rightFilterBarButton, rightSearchBarButton], animated: false)
    }
    
    
    @objc func searchButtonTapped(_ barButton: UIBarButtonItem) {
        print("Search bar button tapped in Movies Collection VC")
        // TODO: implement search input controller
    }
    
    @objc func filterButtonTapped(_ barButton: UIBarButtonItem) {
        print("Filter Button tapped in Movie Collectoin VC")
        
        toggleFilterTableViewUI()
    }
    
    // MARK: Filter UI Methods
    
    @objc func toggleFilterTableViewUI() {
        if filtersContainerView.isUserInteractionEnabled {
            disableFilterTableViewUI(animated: true)
            undimCollectionView()
            collectionView.isScrollEnabled = true
        }
        else {
            enableFilterTableViewUIUpdates()
            dimCollectionView()
            collectionView.isScrollEnabled = false
        }
    }
    
    func enableFilterTableViewUIUpdates() {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.filtersContainerView.alpha = 1
        })
        filtersContainerView.isUserInteractionEnabled = true
    }
    
    func disableFilterTableViewUI(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: { [unowned self] in
            self.filtersContainerView.alpha = 0
        })
        filtersContainerView.isUserInteractionEnabled = false
    }
    
    func dimCollectionView() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleFilterTableViewUI))
        
        let dimView = UIView(frame: view.frame)
        dimView.backgroundColor = .black
        dimView.alpha = 0.0
        dimView.tag = 2
        dimView.addGestureRecognizer(tapGestureRecognizer)
        view.insertSubview(dimView, at: 1)
        
        UIView.animate(withDuration: 0.2) {
            dimView.alpha = 0.6
        }
    }

    func undimCollectionView() {
        
        for subview in view.subviews {
            if subview.tag == 2 {
                UIView.animate(withDuration: 0.2, animations: {
                    subview.alpha = 0.0
                }, completion: { (complete) in
                    subview.removeFromSuperview()
                })
                break
            }
        }
    }
    
}

extension MAMoviesVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Constants.Dimensions.CollectionViewMovieCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.Dimensions.CollectionViewMovieEdgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Four from the end of data source is last row
        if indexPath.row == MADataStore.shared.movies.count - 4 {
            resultsPage += 1
            filterParamDict[Constants.TMDB.Parameters.Page] = String(resultsPage)
            askDataStoreToCallForMoviesIfEmptyOrParamsChanged()
        }
    }
}

