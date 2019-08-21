//
//  User.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 4/27/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit
class User {
    
    let uid: String
    var email:  String
    var firstName: String
    var lastName: String
    var address: String
    var zip: String
    var phoneNumber: String
    var events: [String]

    
    
    
    init(uid: String, email: String, firstName: String, lastName: String, address: String, zip: String, phoneNumber: String, events: [String]) {
        
        self.uid = uid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.zip = zip
        self.phoneNumber = phoneNumber
        self.events = events
        
        
    }
    
//    func save(completion: @escaping (Error?) -> Void) {
//        //1. reference the database
//        let ref = DBReference.users(uid: uid).reference()
//
//        //2. setValue to the reference
//        ref.setValue(toDictionary())
//
//    }
    
    func toDictionary() -> [String : Any] {
        
        return [
            "uid" : uid,
            "email": email,
            "firstName" : firstName,
            "lastName" : lastName,
            "address" : address,
            "zip" : zip,
            "phoneNumber" : phoneNumber,
            "events" : events
        ]
        
    }
    
    //    func saveToProjectsWith(projects: [String]) -> Void {
    //
    //        let ref = DBReference.users(uid: uid).reference().child("projects")
    //        ref.setValue([String:Bool])
    //
    //    }
    
}

