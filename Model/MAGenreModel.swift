//
//  MAGenreModel.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 2/20/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAGenreModel: NSObject {
    
    var id: Int
    var name: String?
    var imagePathString: String?
    var genreImage: UIImage?
    
    init(id: Int, name: String?) {
        self.id = id
        self.name = name
        self.imagePathString = nil
        self.genreImage = nil
    }
    
    init(id: Int, name: String?, imagePathString: String?, genreImage: UIImage?, mostRecentMovieId: Int) {
        self.id = id
        self.name = name
        self.imagePathString = imagePathString
        self.genreImage = genreImage
    }
}
