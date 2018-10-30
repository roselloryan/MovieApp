//
//  MAViewControllerExtension.swift
//  MovieApp
//
//  Created by RYAN ROSELLO on 2/20/18.
//  Copyright © 2018 RYAN ROSELLO. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func presentAlertWith(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    func dimScreenWithActivitySpinner() {
        
        DispatchQueue.main.async { [unowned self] in
            
            // Add dimmed view
            let dimmedView = UIView(frame: self.view.window?.frame ?? self.view.frame)
            dimmedView.tag = 1
            dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.view.addSubview(dimmedView)
            
            // Add activity indicator
            let spinnerView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.whiteLarge)
            spinnerView.tag = 1
            spinnerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - self.navigationController!.navigationBar.frame.height)
            self.view.addSubview(spinnerView)
            spinnerView.startAnimating()
        }
    }
    
    func undimScreenAndRemoveActivitySpinner() {
        
        DispatchQueue.main.async { [unowned self] in
            
            if let window = self.view {
            
                for view in window.subviews {
                    
                    if view.tag == 1 {
                        
                        view.removeFromSuperview()
                    }
                }
            }
        }
    }
    
}
