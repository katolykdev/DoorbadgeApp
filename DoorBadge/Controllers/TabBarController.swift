//
//  TabBarController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/14/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import Firebase

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        let selectedColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        self.navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}
