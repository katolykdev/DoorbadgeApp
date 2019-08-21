//
//  FullImageViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/25/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit

class FullImageViewController: UIViewController {
    
    let zoomImageView = UIImageView()
    let startingFrame = CGRect(x: 0, y: 0, width: 200, height: 100)
    let zoomVidView = UIView()
    
    
    override func viewDidLoad() {
      
        
        zoomImageView.frame = startingFrame
        zoomImageView.image = UIImage(named: "photoIcon")
        zoomImageView.backgroundColor = UIColor.red
        zoomImageView.contentMode = .scaleAspectFit
        zoomImageView.clipsToBounds = true
        zoomImageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(animate)))
   
        view.addSubview(zoomImageView)
        

        
    }
    
   @objc func animate() {
        UIView.animate(withDuration: 3.0) {
            
            let height = (self.view.frame.width / self.startingFrame.width) * self.startingFrame.height
            
            let y = self.view.frame.height / 2

            self.zoomImageView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)

        }
    }
   
}
