//
//  MAFilterTableViewCell.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 3/2/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAFilterTableViewCell: UITableViewCell {
    
    var sortBy: SortBy! {
        didSet {
            updateTextLabel()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func updateTextLabel() {
        DispatchQueue.main.async { [unowned self] in
            self.textLabel?.text = self.sortBy.rawValue
        }
    }

}
