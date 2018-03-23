//
//  MAMovieDetailTableVCTableViewController.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 3/19/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAMovieDetailTableVC: UITableViewController {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var popularityPercentageLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    var tableViewBackgroundImageView: UIImageView?
    
    var movie: MAMovieModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    }
    
    @objc func updateUI() {
        print("update ui in detial table vc!")
        
        DispatchQueue.main.async { [unowned self] in
            self.posterImageView.image = self.movie.posterImage ?? UIImage(named: Constants.ImageNames.Placeholder)
            self.backgroundImageView.image = nil
            self.backgroundImageView.backgroundColor = .clear
            
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
            
            
            
            self.undimScreenAndRemoveActivitySpinner()
        }
    }
    
    func createGradientView() {
        
        let gradientVeiw = GradientView(frame: tableView.bounds)
        self.tableView.backgroundView?.addSubview(gradientVeiw)
    }
    
    @IBAction func button1Tapped(_ sender: UIButton) {
        print("Button 1 tapped")
    }
    
    @IBAction func button2Tapped(_ sender: UIButton) {
        print("Button 2 tapped")
    }
    
    @IBAction func button3Tapped(_ sender: UIButton) {
        print("Button 3 tapped")
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

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        if let imageView = tableViewBackgroundImageView {
            let y = scrollView.contentOffset.y
            
            if y > 0 {
                imageView.frame.origin = CGPoint(x: imageView.frame.origin.x, y: -(y/2.0))
            }
            else {
                imageView.frame.origin  = CGPoint.zero
            }
        }
    }
}
