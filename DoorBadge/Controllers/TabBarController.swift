//
//  TabBarController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/14/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Firebase
import MBProgressHUD

class TabBarController: UITabBarController, SpinnerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        showHUD()
        
        DataManager.getData {
            ((self.selectedViewController as? UINavigationController)?.viewControllers.first as? UpdatableViewController)?.update()
            self.hideHUD()
        }
    }
}
