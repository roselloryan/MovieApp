//
//  MAMovieDetailTableVCTableViewController.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 3/19/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit
import WebKit

class MAMovieDetailTableVC: UITableViewController {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var popularityPercentageLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    @IBOutlet weak var castTitleLabel: UILabel!
    @IBOutlet weak var castCollectionView: UICollectionView!

    @IBOutlet weak var plotSummaryTextView: UITextView!
    
    var tableViewBackgroundImageView: UIImageView?
    var tableViewBackgroundY: CGFloat = 0.0
    
    var webView: WKWebView!
    var movie: MAMovieModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        castCollectionView.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: Constants.Identifiers.CastCollectionViewCell)
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
    
        roundButtonsCorners()
        setButtonTitles()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: Constants.NotificationNames.UpdateDetailVC, object: nil)
        
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        
        // Call for movie details from model id
        if !movie.hasDetails {
            print("movie id: \(movie.id)")
            dimScreenWithActivitySpinner()
            // Ask data store to call for movie details
            MADataStore.shared.getMediaDetailsForMovie(movie: movie)
        }
        
        print(movie.id)
        movieTitleLabel.text = movie.title
        popularityPercentageLabel.text = movie.popularity == nil ? "Popularity: unknown" : "Popularity: " + String(format: "%.1f", movie.popularity!) + "%"
        
        setCollectionViewHeight()
    }

    fileprivate func setButtonTitles() {
        button1.setTitle("Trailer", for: .normal)
        button2.setTitle("Website", for: .normal)
        button3.setTitle("Add To List", for: .normal)
    }
    
    fileprivate func roundButtonsCorners() {
        button1.layer.cornerRadius = 8.0
        button2.layer.cornerRadius = 8.0
        button3.layer.cornerRadius = 8.0
    }
    
    fileprivate func setMoviePosterImage() {
        self.posterImageView.image = self.movie.posterImage ?? UIImage(named: Constants.ImageNames.Placeholder)
    }
    
    fileprivate func setCollectionViewHeight() {
        castCollectionView.frame = CGRect.init(x: castCollectionView.frame.origin.x, y: castCollectionView.frame.origin.y, width: castCollectionView.frame.width, height: Constants.Dimensions.CollectionViewMovieCellSize.height)
    }
    
    @objc func updateUI() {
        print("update ui in detial table vc!")
        
        DispatchQueue.main.async { [unowned self] in
            
            self.setMoviePosterImage()
            
            // see what background image does?
            let backgroundContainerView = UIView(frame: self.tableView.bounds)
            
            let tableViewImageView = UIImageView(frame: self.view.bounds)
            self.tableViewBackgroundImageView = tableViewImageView
            tableViewImageView.contentMode = .scaleAspectFill
            tableViewImageView.image = self.movie.backdropImage ?? UIImage(named: Constants.ImageNames.Placeholder)
            
            let gradientVeiw = GradientView(frame: self.tableView.bounds)
            tableViewImageView.addSubview(gradientVeiw)
            
            self.tableView.backgroundView = backgroundContainerView
            backgroundContainerView.addSubview(tableViewImageView)
            
            self.tableViewBackgroundY = self.tableViewBackgroundImageView!.frame.origin.y
            
            self.updatePlotSummaryTextView()
    
            self.updateWebsiteLinkButton()
            
            self.undimScreenAndRemoveActivitySpinner()
        }
    }
    
    func updateWebsiteLinkButton() {
        if movie.websiteLink == nil {
            button2.isEnabled = false
            button2.removeFromSuperview()
            button2.alpha = 0.0
            buttonsStackView.addArrangedSubview(button2)
        }   
    }
    
    func updatePlotSummaryTextView() {
        if let plot = movie.plotSummary {

            plotSummaryTextView.text = plot
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        }
        else {
            print("No plot for movie. What should you see?")
        }
    }
    
    func createGradientView() {
        
        let gradientVeiw = GradientView(frame: tableView.bounds)
        self.tableView.backgroundView?.addSubview(gradientVeiw)
    }
    
    @IBAction func button1Tapped(_ sender: UIButton) {
        print("Button 1 tapped")
        
        // TODO: Open the trailer link

        let  webVC = UIViewController()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: tableView.frame, configuration: webConfiguration)
        
        
        let myURL = URL(string: "https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        webVC.view = webView

        navigationController?.pushViewController(webVC, animated: true)
    
    }
    
    
    @IBAction func button2Tapped(_ sender: UIButton) {
        print("Button 2 tapped")
        // TODO: Open the website link
        
        if let link = URL(string: movie.websiteLink ?? "https://www.apple.com") {
            UIApplication.shared.open(link)
        }
    }
    
    @IBAction func button3Tapped(_ sender: UIButton) {
        print("Button 3 tapped")
        // TODO: ADD TO THE FUCKING LIST ALREADY
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isKind(of: UITableView.self) {
            if let imageView = tableViewBackgroundImageView {
                let yOffset = scrollView.contentOffset.y
            
                imageView.frame.origin.y = yOffset > 0 ? tableViewBackgroundY - (yOffset / 2.0) : tableViewBackgroundY
            }
        }
        else {
            print("collection view is probably scrolling")
        }
    }
}

// MARK: Cast Collection View Extension
extension MAMovieDetailTableVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifiers.CastCollectionViewCell, for: indexPath) as! CastCollectionViewCell
    
        
        return cell
    }
    
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

