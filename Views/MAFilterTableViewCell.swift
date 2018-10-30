//
//  MAFilterTableViewCell.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 3/2/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

enum CellState {
    case selected
    case unselected
    case pointingDown
    case pointingUp
}

class MAFilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var cellStateImageView: UIImageView!
    
    var sortBy: SortBy? {
        didSet {
            if sortBy != nil {
                nullifyPropertiesExceptSortby()
                updateTextLabel()
            }
        }
    }
    var language: Language? {
        didSet {
            if language != nil {
                nullifyPropertiesExceptLanguage()
                updateTextLabel()
            }
        }
    }
    var filter: Filter? {
        didSet {
            if filter != nil {
                nullifyPropertiesExceptFilter()
                updateTextLabel()
            }
        }
    }
    var rating: Rating? {
        didSet {
            if rating != nil {
                nullifyPropertiesExceptRating()
                updateTextLabel()
                updateCellForRating()
            }
        }
    }
    var cellState: CellState! {
        didSet {
            updateAccessoryImage()
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
        self.textLabel?.textColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func updateCellForRating() {
        
        guard let rating = rating else { fatalError("No rating but trying to update ui in cell \(#function)") }
        
        var photoName: String!
        
        switch rating {
        case .zeroStars:
            photoName = Constants.ImageNames.ZeroStarsAndUp
        case .oneStar:
            photoName = Constants.ImageNames.OneStarsAndUp
        case .twoStars:
            photoName = Constants.ImageNames.TwoStarsAndUp
        case .threeStars:
            photoName = Constants.ImageNames.ThreeStarsAndUp
        case .fourStars:
            photoName = Constants.ImageNames.FourStarsAndUp
        case .fiveStars:
            photoName = Constants.ImageNames.FiveStarsOnly
        }
        
        DispatchQueue.main.async {
            self.titleImageView?.image = UIImage(named: photoName)
        }
    }
    
    
    private func updateAccessoryImage() {
      
        let imageName: String!
        
        guard let cellState = self.cellState else { fatalError("Something wrong in cell state table view cell \(#function)") }
        
        switch cellState {
        case .unselected:
            imageName = Constants.ImageNames.Unselected
        case .selected:
            imageName = Constants.ImageNames.Selected
        case .pointingUp:
            imageName = Constants.ImageNames.UpChevron
        case .pointingDown:
            imageName = Constants.ImageNames.DownChevron
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.cellStateImageView.image = UIImage(named: imageName)
        }
    }
    
    private func updateTextLabel() {
        
        let text: String!
        if let sortBy = self.sortBy {
            text = sortBy.rawValue
        }
        else if let filter = self.filter {
            text = filter.cellLabelTextString
        }
        else if let language = self.language {
            text = language.rawValue
        }
        else if rating != nil {
            text = ""
        }
        else {
            text = "Something wrong in the world\n \(#function)"
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.titleImageView.image = nil
            self.textLabel?.text = text
        }
    }
    
    private func nullifyPropertiesExceptFilter() {
        language = nil
        rating = nil
        sortBy = nil
    }
    
    private func nullifyPropertiesExceptLanguage() {
        filter = nil
        rating = nil
        sortBy = nil
    }

    private func nullifyPropertiesExceptRating() {
        filter = nil
        language = nil
        sortBy = nil
    }

    private func nullifyPropertiesExceptSortby() {
        filter = nil
        language = nil
        rating = nil
    }

}
