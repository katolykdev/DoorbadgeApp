//
//  Gift.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/23/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//


import Foundation
import UIKit
import Firebase

struct Gift {
    
    var title: String
    var description: String
    var giver: String
    var eventId: String
    var facilityId: String
    var thankYouSent: Bool
    var mainImage: String
    var secondaryImages: [String]
    var giftId: String
    
    
    var dictionary: [String: Any] {
        return [
            
            "title": title,
            "description": description,
            "giver": giver,
            "eventId": eventId,
            "facilityId": facilityId,
            "thankYouSent": false,
            "mainImage": mainImage,
            "secondaryImages": secondaryImages,
            "giftId": giftId
            
            
        ]
        
    }
    
}


extension Gift: DocumentSerializable {
    
    init?(dictionary: [String: Any]) {
        
        guard let title = dictionary["title"] as? String,
            let description = dictionary["description"] as? String,
            let giver = dictionary["giver"] as? String,
            
            let eventId = dictionary["eventId"] as? String,
            let facilityId = dictionary["facilityId"] as? String,
            let thankYouSent = dictionary["thankYouSent"] as? Bool,
            let mainImage = dictionary["mainImage"] as? String,
            let secondaryImages = dictionary["secondaryImages"] as? [String],
            let giftId = dictionary["giftId"] as? String
            
            
            else {
                return nil
                
        }
        
        self.init(
            
            title: title,
            description: description,
            giver: giver,
            eventId: eventId,
            facilityId: facilityId,
            thankYouSent: thankYouSent,
            mainImage: mainImage,
            secondaryImages: secondaryImages,
            giftId: giftId
            
            
        )
    }
}
