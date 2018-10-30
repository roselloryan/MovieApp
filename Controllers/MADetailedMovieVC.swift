//
//  MADetailedMovieVC.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 4/4/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit
import WebKit

class MADetailedMovieVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var votesLabel: UILabel!

    @IBOutlet weak var logoAndButtonsStackView: UIStackView!
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    @IBOutlet weak var plotSummaryTextView: UITextView!
    
    @IBOutlet weak var castContainerView: UIView!
    
    var castCollectionView: UICollectionView!
    
    var backdropContainerView: UIView!
    var backdropImageView: UIImageView!
    var backdropContainerViewY: CGFloat = 0.0
    
    var webView: WKWebView!
    
    var movie: MAMovieModel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("movie title: \(movie.title!)")
        print("movie id: \(movie.id)")
        
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Identifies main scroll view for parralax scroll in viewDidScroll
        scrollView.tag = 101
        
        if !movie.hasDetails {
            print("movie id: \(movie.id)")
            dimScreenWithActivitySpinner()
            MADataStore.shared.getMediaDetailsForMovie(movie: movie)
        }
        else {
            updateDetailsUI()
        }
        
        setButtonTitles()
        roundButtonsCorners()
        addInsetsForLogoAndButtonsStackView()
        
        
        // Create backdrop methodMETHOD
    
        let maxY = navigationController?.navigationBar.frame.maxY
        let backdropContainerView = UIView(frame: CGRect(x: 0, y: maxY!, width: view.bounds.width, height: view.bounds.height - 2 * maxY!))
        view.insertSubview(backdropContainerView, at: 0)
        
        let backdropImageView = UIImageView()
        backdropContainerView.addSubview(backdropImageView)
        backdropImageView.contentMode = .scaleAspectFill
        backdropImageView.translatesAutoresizingMaskIntoConstraints = false
        
        backdropImageView.topAnchor.constraint(equalTo: backdropContainerView.topAnchor).isActive = true
        backdropImageView.leftAnchor.constraint(equalTo: backdropContainerView.leftAnchor).isActive = true
        backdropImageView.rightAnchor.constraint(equalTo: backdropContainerView.rightAnchor).isActive = true
        backdropImageView.bottomAnchor.constraint(equalTo: backdropContainerView.bottomAnchor).isActive = true
        
        self.backdropContainerView = backdropContainerView
        self.backdropImageView = backdropImageView
        
        self.backdropContainerViewY = backdropContainerView.frame.origin.y
        
        
        
        addGradientToBackdropImageView()
        
        
        addUpdateDetailsObserver()
        addReloadCastObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    func createCastCollectionView() {
        
        let castLabel = UILabel()
        castLabel.translatesAutoresizingMaskIntoConstraints = false
        castLabel.text = "Cast"
        castLabel.font = UIFont.systemFont(ofSize: 17)
        castLabel.textColor = .white
        castLabel.frame = CGRect(x: 0, y: 0, width: castLabel.intrinsicContentSize.width, height: castLabel.intrinsicContentSize.height)
        
        castContainerView.addSubview(castLabel)
    
        castLabel.topAnchor.constraint(equalTo: castContainerView.topAnchor, constant: 8).isActive = true
        castLabel.leftAnchor.constraint(equalTo: castContainerView.leftAnchor, constant: 8).isActive = true
        castLabel.rightAnchor.constraint(equalTo: castContainerView.rightAnchor).isActive = true
        
        let frame = CGRect.zero
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .horizontal

        let castCollectionView = UICollectionView.init(frame: frame, collectionViewLayout: flowlayout)
        castCollectionView.translatesAutoresizingMaskIntoConstraints = false
        castCollectionView.showsHorizontalScrollIndicator = false
        castCollectionView.backgroundColor = .clear
        castCollectionView.tag = 666
        
        castCollectionView.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: Constants.Identifiers.CastCollectionViewCell)
        
        castCollectionView.delegate = self
        castCollectionView.dataSource = self

        print("collection view frame: \(castCollectionView.frame)")

        castContainerView.addSubview(castCollectionView)

        print(castLabel.bottomAnchor)
    
        castCollectionView.topAnchor.constraint(equalTo: castLabel.bottomAnchor, constant: 8).isActive = true
        castCollectionView.leftAnchor.constraint(equalTo: castContainerView.leftAnchor).isActive = true
        castCollectionView.rightAnchor.constraint(equalTo: castContainerView.rightAnchor).isActive = true
    
        // Plus 50 in height is to allow space for collection view cells to show full picture with name label below
        castCollectionView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.CollectionViewMovieCellSize.height + 50).isActive = true
        castContainerView.bottomAnchor.constraint(equalTo: castCollectionView.bottomAnchor, constant: 20).isActive = true
    
        print("collection view frame: \(castCollectionView.frame)")
    
        self.castCollectionView = castCollectionView
    }
    
    @IBAction func button1Tapped(_ sender: UIButton) {
        print("Button 1 tapped")
        if let trailerLink = movie.trailerLink  {
            if let url = URL(string: trailerLink) {
                let  webVC = UIViewController()
                
                let webConfiguration = WKWebViewConfiguration()
                webView = WKWebView(frame: view.frame, configuration: webConfiguration)
                
                let myRequest = URLRequest(url: url)
                
                webView.load(myRequest)
                webVC.view = webView
                
                navigationController?.pushViewController(webVC, animated: true)
            }
        }
    }
    @IBAction func button2Tapped(_ sender: UIButton) {
        // Open website in Safari. Webview didn't like the redirects
        print("Button 2 tapped")
        if let link =  movie.websiteLink {
            if let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
            else {
                print("Link url failed")
            }
        }
        else {
            print("no website link ")
        }
        
    }
    @IBAction func button3Tapped(_ sender: UIButton) {
        // TODO: Please for the love of god, add the movie to a list. Any list.
        print("Please for the love of god, add the movie to a list. Any list.")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func updateDetailsUI() {
        print("update ui in movie detial vc!")
        
        DispatchQueue.main.async { [unowned self] in
            
            self.updateTitleLabel()
            self.setRatingImage()
            self.updateVotesLabel()
            
            self.setMoviePosterImage()
            self.updatePlotSummaryTextView()
            self.setBackdropImage()
            
            self.createCastCollectionView()
            
            // TODO: implement this if you want to remove or disable button
//            self.updateWebsiteLinkButton()
            
            self.undimScreenAndRemoveActivitySpinner()
        }
    }
    
    @objc private func reloadCast(notification: Notification) {
        if let userInfo = notification.userInfo, let movieId = userInfo[Constants.NotificationKeys.MovieId] as? Int {
            if movieId == movie.id {
                DispatchQueue.main.async {
                    self.castCollectionView.reloadData()
                }
            }
        }
    }
    
    fileprivate func updateTitleLabel() {
        movieTitleLabel.text = movie.title ?? ""
    }
    
    fileprivate func setRatingImage() {
        ratingsImageView.image = movie.voteAverage != nil ? imageForVoteAverage(voteAverage: movie.voteAverage!) : nil
    }
    
    fileprivate func imageForVoteAverage(voteAverage: Double) -> UIImage {
        // Average vote range 0-10

        switch voteAverage {
        case 0.0..<0.5:
            return UIImage(named: Constants.ImageNames.ZeroStars)!
        case 0.5..<1.5:
            return UIImage(named: Constants.ImageNames.HalfStar)!
        case 1.5..<2.5:
            return UIImage(named: Constants.ImageNames.OneStar)!
        case 2.5..<3.5:
            return UIImage(named: Constants.ImageNames.OneAndAHalfStars)!
        case 3.5..<4.5:
            return UIImage(named: Constants.ImageNames.TwoStars)!
        case 4.5..<5.5:
            return UIImage(named: Constants.ImageNames.TwoAndAHalfStars)!
        case 5.5..<6.5:
            return UIImage(named: Constants.ImageNames.ThreeStars)!
        case 6.5..<7.5:
            return UIImage(named: Constants.ImageNames.ThreeAndAHalfStars)!
        case 7.5..<8.5:
            return UIImage(named: Constants.ImageNames.FourStars)!
        case 8.5..<9.5:
            return UIImage(named: Constants.ImageNames.FourAndAHalfStars)!
        case 9.5...10.0:
            return UIImage(named: Constants.ImageNames.FiveStars)!
        default:
            fatalError("average vote problem in \(#function)")
        }
    }
    
    fileprivate func updateVotesLabel() {
        votesLabel.text = movie.voteCount != nil ? "\(movie.voteCount!) Votes" : ""
    }
    
    fileprivate func setBackdropImage() {
        backdropImageView.image = movie.backdropImage ?? nil
    }
    
    fileprivate func addGradientToBackdropImageView() {
        let gradientVeiw = GradientView(frame: self.backdropImageView.bounds)
        backdropImageView.addSubview(gradientVeiw)
    }
    
    fileprivate func setMoviePosterImage() {
        posterImageView.image = movie.posterImage ?? UIImage(named: Constants.ImageNames.PosterPlaceholder)
    }
    
    fileprivate func updatePlotSummaryTextView() {
        plotSummaryTextView.text = movie.plotSummary ?? ""
    }
    
    
    
    fileprivate func setButtonTitles() {
        button1.setTitle("Trailer", for: .normal)
        button2.setTitle("Website", for: .normal)
        button3.setTitle("Add To List", for: .normal)
    }
    
    fileprivate func roundButtonsCorners() {
        button1.layer.cornerRadius = 5.0
        button2.layer.cornerRadius = 5.0
        button3.layer.cornerRadius = 5.0
    }
    
    fileprivate func addInsetsForLogoAndButtonsStackView() {
        logoAndButtonsStackView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        logoAndButtonsStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    fileprivate func addUpdateDetailsObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateDetailsUI), name: Constants.NotificationNames.UpdateDetailVC, object: nil)
    }
    
    fileprivate func addReloadCastObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCast(notification:)), name: Constants.NotificationNames.ReloadCast, object: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Tag to differentiate between main scroll view and cast collection view
        print(scrollView.tag)
        if scrollView.tag == 101 {
            
            print(scrollView.tag)
            if let containerView = backdropContainerView {
                
                let yOffset = scrollView.contentOffset.y
                containerView.frame.origin.y = backdropContainerViewY - (yOffset / 2.0)
            }
        }
        else {
            // THis is cast collection view scrolling
        }
    }

  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
// MARK: Cast Collection View Extension
extension MADetailedMovieVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movie.cast?.count == nil ? 0 : movie.cast!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifiers.CastCollectionViewCell, for: indexPath) as! CastCollectionViewCell
        
        let castMemberDict = movie.cast![indexPath.row] as [String: Any]
        let name = castMemberDict[Constants.TMDBDictKeys.Name] as! String
        
        cell.nameLabel.text = name
        //        cell.layoutIfNeeded() // TODO: Does this need to be called?
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: Constants.Dimensions.CollectionViewMovieCellSize.width, height: Constants.Dimensions.CollectionViewMovieCellSize.height + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return Constants.Dimensions.CollectionViewMovieEdgeInsets
    }

}

