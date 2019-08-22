//
//  Event.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 4/27/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Event {
    
    var age: String
    var date: String
    var dateOfBirth: String
    var dateOfDeath: String
    var eventFirstName: String
    var eventLastName: String
    var description: String
    var eventId: String
    var eventCode: String
    var facilityId: String
    var familyAddress: String
    var familyFirstName: String
    var familyLastName: String
    var familyModeOfContact: String
    var familyPhone: String
    var familyZip: String
    var image: String
    var location: String
    var primaryUserEmail: String
    var primaryUserId: String
    var title: String
    var type: String
    var isOpen: Bool

    var dictionary: [String: Any] {
        return [
        "age": age,
        "date": date,
        "dateOfBirth": dateOfBirth,
        "dateOfDeath": dateOfDeath,
        "eventFirstName": eventFirstName,
        "eventLastName": eventLastName,
        "description": description,
        "eventId": eventId,
        "eventCode": eventCode,
        "facilityId": facilityId,
        "familyAddress": familyAddress,
        "familyFirstName": familyFirstName,
        "familyLastName": familyLastName,
        "familyModeOfContact": familyModeOfContact,
        "familyPhone": familyPhone,
        "familyZip": familyZip,
        "image": image,
        "location": location,
        "primaryUserEmail": primaryUserEmail,
        "primaryUserId": primaryUserId,
        "title": title,
        "type": type,
        "isOpen": isOpen
        ]
    }
}

extension Event: DocumentSerializable {
    
    init?(dictionary: [String: Any]) {
        
        guard let age = dictionary["age"] as? String,
            let date = dictionary["date"] as? String,
            let dateOfBirth = dictionary["dateOfBirth"] as? String,
            let dateOfDeath = dictionary["dateOfDeath"] as? String,
            let eventFirstName = dictionary["eventFirstName"] as? String,
            let eventLastName = dictionary["eventLastName"] as? String,
            let description = dictionary["description"] as? String,
            let eventId = dictionary["eventId"] as? String,
            let eventCode = dictionary["eventCode"] as? String,
            let facilityId = dictionary["facilityId"] as? String,
            let familyAddress = dictionary["familyAddress"] as? String,
            let familyFirstName = dictionary["familyFirstName"] as? String,
            let familyLastName = dictionary["familyLastName"] as? String,
            let familyModeOfContact = dictionary["familyModeOfContact"] as? String,
            let familyPhone = dictionary["familyPhone"] as? String,
            let familyZip = dictionary["familyZip"] as? String,
            let image = dictionary["image"] as? String,
            let location = dictionary["location"] as? String,
            let primaryUserEmail = dictionary["primaryUserEmail"] as? String,
            let primaryUserId = dictionary["primaryUserId"] as? String,
            let title = dictionary["title"] as? String,
            let type = dictionary["type"] as? String,
            let isOpen = dictionary["isOpen"] as? Bool
            else {
                return nil
        }
        
        self.init(
            age: age,
            date: date,
            dateOfBirth: dateOfBirth,
            dateOfDeath: dateOfDeath,
            eventFirstName: eventFirstName,
            eventLastName: eventLastName,
            description: description,
            eventId: eventId,
            eventCode: eventCode,
            facilityId: facilityId,
            familyAddress: familyAddress,
            familyFirstName: familyFirstName,
            familyLastName: familyLastName,
            familyModeOfContact: familyModeOfContact,
            familyPhone: familyPhone,
            familyZip: familyZip,
            image: image,
            location: location,
            primaryUserEmail: primaryUserEmail,
            primaryUserId: primaryUserId,
            title: title,
            type: type,
            isOpen: isOpen
        )
    }
}
