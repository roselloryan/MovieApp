//
//  CastCollectionViewCell.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 3/27/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class CastCollectionViewCell: UICollectionViewCell {
    
    var castImageView: UIImageView!
    var nameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildCellUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildCellUI()
    }
    
    func buildCellUI() {
        
        let imageView = UIImageView(image: UIImage(named:"CastImage"))
        imageView.contentMode = .scaleAspectFill
        
        castImageView = imageView
        contentView.addSubview(castImageView)
        
        castImageView.translatesAutoresizingMaskIntoConstraints = false
        castImageView.clipsToBounds = true
        
        castImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        castImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        castImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        castImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor , multiplier: 1.51).isActive = true
        
        

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 30))
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .clear
        label.numberOfLines = 2
        
        nameLabel = label
        contentView.addSubview(nameLabel)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.topAnchor.constraint(equalTo: castImageView.bottomAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true        
        contentView.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
    }
}
