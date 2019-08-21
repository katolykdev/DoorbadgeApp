//
//  Family.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 6/12/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Family {
    
   
    
    var email:  String
    
    var events: [String]
    
    
    var dictionary: [String : Any] {
        
        return [
            
            
            "email": email,
           
            "events" : events
            
        ]
        
    }
    
}

extension Family: DocumentSerializable {
    
    init?(dictionary: [String: Any]) {
        
        guard let email = dictionary["email"] as? String,
           
            let events = dictionary["events"] as? [String]
           
            
            else {
                return nil
                
        }
        
        self.init(
            

            email: email,
           
            events: events
           
            
        )
    }
}
