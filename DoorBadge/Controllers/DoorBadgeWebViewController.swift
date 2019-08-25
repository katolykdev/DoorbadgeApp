//
//  DoorBadgeWebViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/5/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var backButtonDoorBadge: UIButton!
    @IBOutlet weak var closeButtonWebDoorBagde: UIButton!
    @IBOutlet weak var webView: WKWebView!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentFacility: Facility!
    
    var urlString = "https://www.google.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentFacility = appDelegate.currentFacility
    }
    
    @IBAction func closeWebModal(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let urlString = FacilityEvents.loggedInFacility?.website {
            print(urlString)
            if urlString != "" {
                let http = urlString.prefix(5)
                print(http)
                switch http {
                    case "http:":
                        let newUrlString = urlString.replacingOccurrences(of: "http:", with: "https:")
                        if let url:URL = URL(string: newUrlString) {
                            let urlRequest:URLRequest = URLRequest(url: url)
                            webView.load(urlRequest)
                            print("http:\(urlString)")
                        }
                    case "https":
                         if let url:URL = URL(string: urlString) {
                             let urlRequest:URLRequest = URLRequest(url: url)
                             webView.load(urlRequest)
                             print("https\(urlString)")
                        }
                    default:
                        let newUrlString = "https://" + urlString
                        print(newUrlString)
                        if let url:URL = URL(string: newUrlString) {
                          
                            webView.load(URLRequest(url: url))
                            print("default\(urlString)")
                        }
                    }
            } else {
                if let url:URL = URL(string: "https://doorbadge.com") {
                    let urlRequest:URLRequest = URLRequest(url: url)
                    webView.load(urlRequest)
                }
            }
        }
    }
}
