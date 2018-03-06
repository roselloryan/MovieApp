//
//  MAGenreSearchVCTableViewController.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 2/15/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAGenreSearchTVC: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNotificationObservers()
        setRowHeightFromConstants()
        addSearchButtonToNavBar()
    }
    
    deinit {
        removeNotificationObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MADataStore.shared.genres.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.GenreTableViewCell, for: indexPath) as! MAGenreTableViewCell

        let genreModel = MADataStore.shared.genres[indexPath.row] as MAGenreModel
        
        cell.genreModel = genreModel
        
        return cell
    }
    
    func setRowHeightFromConstants() {
        tableView.rowHeight = Constants.Dimensions.TableViewCellHeight ?? 20.0
    }

    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Identifiers.MovieCollectionViewSegue {
            if let destinationVC = segue.destination as? MAMoviesVC {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    destinationVC.genre = (tableView.cellForRow(at: selectedIndexPath) as! MAGenreTableViewCell).genreModel
                }
            }
            else {
                fatalError("Not casting destinationVC in \(#function)")
            }
        }
        
    }
    

    func addObserverForDataReload() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReload), name: Constants.NotificationNames.GenreReload, object: nil)
    }
    
    func addObserverForErrors() {
        NotificationCenter.default.addObserver(self, selector: #selector(postErrorFromNotification(_:)), name: Constants.NotificationNames.Error, object: nil)
    }
    
    func removeObserverForError() {
        NotificationCenter.default.removeObserver(self, name: Constants.NotificationNames.Error, object: nil)
    }

    func removeObserverForDataReload() {
        NotificationCenter.default.removeObserver(self, name: Constants.NotificationNames.GenreReload, object: nil)
    }
    
    func addNotificationObservers() {
        addObserverForDataReload()
        addObserverForErrors()
    }
    
    func removeNotificationObservers() {
        removeObserverForDataReload()
        removeObserverForError()
    }
    
    @objc func notificationReload() {
        
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    @objc func postErrorFromNotification(_ notification: Notification) {
        
        // TODO: if this is visible view controller present else no.
        
        print("In postErrorFromNotification.\nNotification: \(notification)")
      
        if let userInfo = notification.userInfo as? Dictionary<String, Any> {
            print("In post error GenreSearchTVC Funtionn\(#function)")
            let title = userInfo[Constants.ErrorKeys.Title] as? String ?? "Title failed in postErrorFromNotification(_:)"
            let message = userInfo[Constants.ErrorKeys.Message] as? String ?? "Message failed in postErrorFromNotification(_:)"

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
    
    // MARK: - Navigation bar methods
    
    func addSearchButtonToNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
    }
    
    @objc func searchButtonTapped(_ barButton: UIBarButtonItem) {
        print("Search bar button tapped")
        // TODO: implement search input controller
    }

}
