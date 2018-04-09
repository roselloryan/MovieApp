//
//  MAMovieCollectionViewCell.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 2/27/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAMovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    var movie: MAMovieModel! {
        didSet {
            updateTitleLabel()
            updateMoviePosterImage()
        }
    }
    
    // MARK: - Methods
    private func updateTitleLabel() {
        DispatchQueue.main.async { [unowned self] in
            self.titleLabel.text = self.movie.posterImage == nil ? self.movie.title : ""
        }
    }
    
    private func updateMoviePosterImage() {
        DispatchQueue.main.async { [unowned self] in
            self.posterImageView.image = self.movie.posterImage ?? UIImage(named: Constants.ImageNames.Placeholder)
//            self.posterImageView.image = self.movie.posterImage
        }
    }
    
}
