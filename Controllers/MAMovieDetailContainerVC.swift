//
//  MAMovieDetailContainerVC.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 3/19/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import UIKit

class MAMovieDetailContainerVC: UIViewController {
    
    var movie: MAMovieModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.children)
        
        if movie != nil && children.first != nil {
            (children.first as! MAMovieDetailTableVC).movie = movie
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
