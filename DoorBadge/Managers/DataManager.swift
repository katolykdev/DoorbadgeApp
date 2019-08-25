//
//  DataManager.swift
//  DoorBadge
//
//  Created by Seweryn Katolyk on 8/25/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct DataManager {
    static func getFacility(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let facilityRef = Firestore.firestore().collection("facilities").document("\(user.uid)")
        
        facilityRef.getDocument { (document, error) in
            guard let facility = document.flatMap({
                $0.data().flatMap({ Facility(dictionary: $0) })
            }) else {
                return
            }
            
            FacilityEvents.loggedInFacility = facility
            if let currentFacility = FacilityEvents.loggedInFacility {
                let events = currentFacility.events
                
                for event in events {
                    let eventRef = Firestore.firestore().collection("events").document(event)
                    
                    eventRef.getDocument { (document, error) in
                        guard let event = document.flatMap({
                            $0.data().flatMap({ Event(dictionary: $0) })
                        }) else {
                            return
                        }
                        
                        guard event.isOpen else { return }
                        FacilityEvents.currentEvents.append(event)
                    }
                    completion()
                }
            }
        }
    }
}
