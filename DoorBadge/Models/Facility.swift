//
//  Facility.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/13/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Facility {
    
    let uid: String
    var name: String
    var email:  String
    var firstName: String
    var lastName: String
    var address: String
    var phone: String
    var events: [String]
    var website: String
    var city: String
    var state: String
    var zipCode: String
    
    var dictionary: [String : Any] {
        
        return [
            "uid" : uid,
            "name": name,
            "email": email,
            "firstName" : firstName,
            "lastName" : lastName,
            "address" : address,
            "phone" : phone,
            "events" : events,
            "website": website,
            "city": city,
            "state": state,
            "zipCode": zipCode
        ]
        
    }

}

extension Facility: DocumentSerializable {
    
    init?(dictionary: [String: Any]) {
        
        guard let uid = dictionary["uid"] as? String,
            let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String,
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let address = dictionary["address"] as? String,
            let phone = dictionary["phone"] as? String,
            let events = dictionary["events"] as? [String],
            let website = dictionary["website"] as? String,
            let city = dictionary["city"] as? String,
            let state = dictionary["state"] as? String,
            let zipCode = dictionary["zipCode"] as? String
            
            else {
                return nil
                
        }
        
        self.init(
            
            uid: uid,
            name: name,
            email: email,
            firstName: firstName,
            lastName: lastName,
            address: address,
            phone: phone,
            events: events,
            website: website,
            city: city,
            state: state,
            zipCode: zipCode
            
        )
    }
}
