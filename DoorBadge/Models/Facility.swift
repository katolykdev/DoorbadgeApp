//
//  Facility.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/13/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
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
        
        guard let uid = dictionary[stringFor: "uid"],
            let email = dictionary[stringFor: "email"],
            let events = dictionary["events"] as? [String]
            else {
                return nil
        }
        
        self.init(
            uid: uid,
            name: dictionary[stringFor: "name"] ?? "",
            email: email,
            firstName: dictionary[stringFor: "firstName"] ?? "",
            lastName: dictionary[stringFor: "lastName"] ?? "",
            address: dictionary[stringFor: "address"] ?? "",
            phone: dictionary[stringFor: "phone"] ?? "",
            events: events,
            website: dictionary[stringFor: "website"] ?? "",
            city: dictionary[stringFor: "city"] ?? "",
            state: dictionary[stringFor: "state"] ?? "",
            zipCode: dictionary[stringFor: "zipCode"] ?? ""
        )
    }
}
