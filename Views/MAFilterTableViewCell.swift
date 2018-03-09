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
    var cellState: CellState! {
        didSet {
            updateAccessoryImage()
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func updateAccessoryImage() {
      
        let imageName: String!
        
        switch self.cellState {
        case .unselected:
            imageName = Constants.ImageNames.Unselected
        case .selected:
            imageName = Constants.ImageNames.Selected
        case .pointingUp:
            imageName = Constants.ImageNames.UpChevron
        case .pointingDown:
            imageName = Constants.ImageNames.DownChevron
        default:
            fatalError("Something wrong in cell state table view cell \(#function)")
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.accessoryView = UIImageView(image: UIImage(named: imageName))
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
        else {
            text = "Something wrong in the world\n \(#function)"
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.textLabel?.text = text
        }
    }
    
    private func nullifyPropertiesExceptFilter() {
        language = nil
        sortBy = nil
    }
    
    private func nullifyPropertiesExceptSortby() {
        filter = nil
        language = nil
    }
    private func nullifyPropertiesExceptLanguage() {
        filter = nil
        sortBy = nil
    }

}
