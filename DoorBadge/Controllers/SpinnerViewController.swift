//
//  SpinnerViewController.swift
//  vindecoder
//
//  Created by Admin on 2/21/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol SpinnerViewController: class {
    func showHUD(msg: String)
    func hideHUD()
}

extension SpinnerViewController where Self: UIViewController {
    func showHUD(msg: String = "") {
        let mHub = MBProgressHUD.showAdded(to: view, animated: true)
        mHub.label.text = msg
        mHub.isUserInteractionEnabled = false
    }
    
    func hideHUD() {
        MBProgressHUD.hide(for: view, animated: true)
    }
}
