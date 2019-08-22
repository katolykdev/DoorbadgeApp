//
//  DoorBadgeSettingsViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/13/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore


class DoorBadgeSettingsViewController: UIViewController  {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentFacility: Facility!
    
    let defaults = UserDefaults.standard
    
    var logInType = ""
    
    @IBOutlet var facilityNameLabel: UILabel!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var phoneLabel: UILabel!
    
    @IBOutlet var emailLabel: UILabel!
    
    @IBOutlet var firstNameLabel: UILabel!
    
    @IBOutlet var lastNameLabel: UILabel!
    
    @IBOutlet var websiteLabel: UILabel!
    
    @IBOutlet weak var facilityName: UILabel!
    @IBOutlet weak var facilityAddress: UILabel!
    @IBOutlet weak var facilityPhone: UILabel!
    @IBOutlet weak var facilityEmail: UILabel!
    @IBOutlet weak var facilityFirstName: UILabel!
    @IBOutlet weak var facilityLastName: UILabel!
    @IBOutlet weak var facilityWebsite: UILabel!
    
    @IBOutlet weak var doorBadgeLogOutButton: UIButton!
    
    @IBAction func doorBadgeLogOutDidPress(_ sender: Any) {
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
        
        performSegue(withIdentifier: "didLogOutToInitial", sender: Any?.self)
    }

    override func viewDidLoad() {
        if defaults.string(forKey: "logInType") == "family" {
            logInType = "family"
        } else {
            logInType = "facility"
        }
        
        if logInType == "facility" {
            currentFacility = FacilityEvents.loggedInFacility
            
            facilityName.text = currentFacility.name
            facilityAddress.text = currentFacility.address
            facilityPhone.text = currentFacility.phone
            facilityEmail.text = currentFacility.email
            facilityFirstName.text = currentFacility.firstName
            facilityLastName.text = currentFacility.lastName
            facilityWebsite.text = currentFacility.website
        } else {
            facilityNameLabel.text = "Logged in as:"
            facilityName.text = Auth.auth().currentUser?.email
            
            facilityAddress.text = ""
            facilityPhone.text = ""
            facilityEmail.text = ""
            facilityFirstName.text = ""
            facilityLastName.text = ""
            facilityWebsite.text = ""
            
            addressLabel.text = ""
            phoneLabel.text = ""
            emailLabel.text = ""
            firstNameLabel.text = ""
            lastNameLabel.text = ""
            websiteLabel.text = ""
        }
    }
}
