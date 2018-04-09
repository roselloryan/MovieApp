//
//  MADetailedMovieVC.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 4/4/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MADetailedMovieVC: UIViewController {
    
    @IBOutlet weak var backdropImageView: UIImageView!
    
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
    
    
    var movie: MAMovieModel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("movie title: \(movie.title!)")
        print("movie id: \(movie.id)")
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        addGradientToBackdropImageView()
        
        addUpdateDetailsObserver()
        
        
        // Call for movie details from model id
        if !movie.hasDetails {
            print("movie id: \(movie.id)")
            dimScreenWithActivitySpinner()
            // Ask data store to call for movie details
            MADataStore.shared.getMediaDetailsForMovie(movie: movie)
        }
    }
    @IBAction func button1Tapped(_ sender: UIButton) {
        // TODO: Open trailer link. Are they all on YouTube?
    }
    @IBAction func button2Tapped(_ sender: UIButton) {
        // TODO: Open website in Safari. Webview didn't like the redirects
    }
    @IBAction func button3Tapped(_ sender: UIButton) {
        // TODO: Please for the love of god, add the movie to a list. Any list. 
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
            
            
            
//            // see what background image does?
//            let backgroundContainerView = UIView(frame: self.view.bounds)
//
//            let parralaximageView = UIImageView(frame: self.view.bounds)
//            self.tableViewBackgroundImageView = parralaximageView
//            parralaximageView.contentMode = .scaleAspectFill
//            parralaximageView.image = self.movie.backdropImage ?? UIImage(named: Constants.ImageNames.Placeholder)
//
//            let gradientVeiw = GradientView(frame: self.view.bounds)
//            parralaximageView.addSubview(gradientVeiw)
//
//            self.tableView.backgroundView = backgroundContainerView
//            backgroundContainerView.addSubview(parralaximageView)
//
//            self.tableViewBackgroundY = self.tableViewBackgroundImageView!.frame.origin.y
        
            
//            self.updateWebsiteLinkButton()
            
            self.undimScreenAndRemoveActivitySpinner()
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
        let gradientVeiw = GradientView(frame: self.view.bounds)
        backdropImageView.addSubview(gradientVeiw)
        
//        self.tableView.backgroundView = backgroundContainerView
//        backgroundContainerView.addSubview(tableViewImageView)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
