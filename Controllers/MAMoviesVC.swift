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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filtersContainerView: UIView!
    
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
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    
    // MARK: - Movie Data Store Related Methods
    
    func askDataStoreToCallForMoviesIfEmptyOrParamsChanged() {
        if MADataStore.shared.movies.count == 0 || filterParamDict != MADataStore.shared.moviesParams {
            dimScreenWithActivitySpinner()
            MADataStore.shared.getMediaListFromTMDBAPIClientWithParameterDict(params: filterParamDict , mediaFormat: .movie)
        }
    }
    
    func defaultFilterParametersDictionary() -> Dictionary<String, String> {
        
        let paramDict = [Constants.TMDB.Parameters.Language: Constants.TMDB.Values.English,
                         Constants.TMDB.Parameters.IncludeAdult: Constants.TMDB.Values.False,
                         Constants.TMDB.Parameters.IncludeVideo: Constants.TMDB.Values.False,
                         Constants.TMDB.Parameters.Page: Constants.TMDB.Values.One,
                         Constants.TMDB.Parameters.SortBy: Constants.TMDB.Values.PopularityDesc,
                         Constants.TMDB.Parameters.PrimaryReleaseDateLessThan: Constants.TMDB.CurrentDate,
                         Constants.TMDB.Parameters.WithGenres: String(genre.id)]
        
        // TODO: change primary release year to current date
        print(Constants.TMDB.CurrentDate)
        
        
        return paramDict
    }
    
    // MARK: - Notification Methods
    func addObserverForDataReload() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReloadData), name: Constants.NotificationNames.MovieReload, object: nil)
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
    
    
    
    func addNotificationObservers() {
        addObserverForDataReload()
        addObserverForReloadCellAtRow()
        addObserverForErrors()
    }
    
    func removeNotificationObservers() {
        removeObserverForDataReload()
        removeObserverForReloadCellAtRow()
        removeObserverForError()
    }
    
    @objc func notificationReloadData() {
        DispatchQueue.main.async { [unowned self] in
            self.collectionView?.reloadData()
        }
    }
    
    @objc func reloadCellAtIndexPathFromNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            if let row = userInfo[Constants.NotificationKeys.Row] as? Int {
                
                DispatchQueue.main.async { [unowned self] in
                    self.undimScreenAndRemoveActivitySpinner()
                    self.collectionView?.reloadItems(at: [IndexPath(row: row, section: 0)])
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
            // TODO: shade and disable collection view
        })
        filtersContainerView.isUserInteractionEnabled = true
    }
    
    func disableFilterTableViewUI(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: { [unowned self] in
            self.filtersContainerView.alpha = 0
            // TODO: un-shade and enable collection view
        })
        filtersContainerView.isUserInteractionEnabled = false
    }
    
    func dimCollectionView() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleFilterTableViewUI))
        
        let dimView = UIView.init(frame: collectionView.bounds)
        dimView.backgroundColor = .black
        dimView.alpha = 0.0
        dimView.tag = 1
        dimView.addGestureRecognizer(tapGestureRecognizer)
        collectionView.addSubview(dimView)
        
        UIView.animate(withDuration: 0.2) {
            dimView.alpha = 0.6
        }
    }

    func undimCollectionView() {
        
        for subview in collectionView.subviews {
            if subview.tag == 1 {
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
}

