//
//  MAGenreTableViewCell.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 2/20/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAGenreTableViewCell: UITableViewCell {
    
    var genreModel: MAGenreModel! {
        didSet {
            updateGenreLabel()
            updateGenreImage()
        }
    }
    
    @IBOutlet weak var genreImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - UI Update functions
    func updateGenreLabel() {
        DispatchQueue.main.async { [unowned self] in
            
            if let genreName = self.genreModel.name {
                
                self.genreLabel.attributedText = NSAttributedString(string: genreName, attributes: Constants.AttributedText.GenreCellsTextAttributes)
            }
        }
    }
    
    func updateGenreImage() {
        DispatchQueue.main.async {
            self.genreImageView.image = self.genreModel.genreImage
        }
    }
    
}
