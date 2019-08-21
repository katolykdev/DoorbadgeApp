//
//  DoorBadgePreLoginViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 4/24/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class DoorBadgePreLogInViewController: UIViewController {
    

    @IBOutlet weak var familyButton: UIButton!
    @IBOutlet weak var facilityButton: UIButton!
    @IBOutlet weak var memoryBookButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var houseIcon: UIImageView!
    
    
    @IBOutlet weak var familyIcon: UIImageView!
    
    @IBOutlet weak var memoryBookIcon: UIImageView!
    

    let generator1 = UIImpactFeedbackGenerator(style: .light)

    
    @IBAction func memoryBookTapped(_ sender: UIButton) {
        sender.pulsate()
        generator1.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.2, execute: {
            self.performSegue(withIdentifier: "showMemoryBookCode", sender: UIButton.self)
        })
        
    }
    

    
    @IBAction func familyButtonDidTap(_ sender: UIButton) {
        LoggedIn.accountType = "family"
        generator1.impactOccurred()
        sender.pulsate()
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.2, execute: {
        self.performSegue(withIdentifier: "toLogIn", sender: UIButton.self)
        })
        
    }
    

    
    @IBAction func facilityButtonDidTap(_ sender: UIButton) {
        LoggedIn.accountType = "facility"
        generator1.impactOccurred()
        sender.pulsate()
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.2, execute: {
        self.performSegue(withIdentifier: "toLogIn", sender: UIButton.self)
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FacilityEvents.currentEvents = []
        FacilityEvents.pastEvents = []
        FacilityEvents.loggedInFacility = nil
        appDelegate.currentFacility = nil
        EventGifts.gifts = []
        LoggedIn.accountType = ""
        FamilyEvents.currentEvents = []
        FamilyEvents.pastEvents = []
        FamilyEvents.loggedInFamily = nil
        
        try! Auth.auth().signOut()
    }
    
    override func viewDidLoad() {
        
        
        
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        //ROUND BUTTONS
        familyButton.layer.cornerRadius = 5
        facilityButton.layer.cornerRadius = 5
        memoryBookButton.layer.cornerRadius = 5
        
        
        //COLOR HOUSE ICON
//        let lightBlue = UIColor(red: 222.0/255.0, green: 227.0/255.0, blue: 236.0/255.0, alpha: 1.0)
        let origHouseImage = houseIcon.image
        let tintedHouseImage = origHouseImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        houseIcon.image = tintedHouseImage
        houseIcon.tintColor = UIColor.white
        
        let origFamilyImage = familyIcon.image
        let tintedFamilyImage = origFamilyImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        familyIcon.image = tintedFamilyImage
        familyIcon.tintColor = UIColor.black
        
        let origMemImage = memoryBookIcon.image
        let tintedMemImage = origMemImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        memoryBookIcon.image = tintedMemImage
        memoryBookIcon.tintColor = UIColor.black
  
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "showMemoryBookCode" {
            
        }
            if let dbLogInVC = segue.destination as? DoorBadgeLogInViewController {
    
                if segue.identifier == "toLogIn" {
                    
                    if LoggedIn.accountType == "family" {
                        
                        dbLogInVC.logInPageTitleText = "Family"
                       
                        
                    } else if LoggedIn.accountType == "facility" {
                        
                        dbLogInVC.logInPageTitleText = "Facility"
                       
                        
                    }
                    
                }
                
            }
        }
            
}

extension UIButton {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(methodTobeCalledEveryWhere), for: .touchUpInside)
    }
    
    @objc func methodTobeCalledEveryWhere () {
          let generator1 = UIImpactFeedbackGenerator(style: .light)
        generator1.impactOccurred()
    }
    
}
