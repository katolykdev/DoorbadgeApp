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

// TODO: (skatolyk) Need to extract one method form getFacility and getFamily
struct DataManager {
    static func getData(completion: @escaping () -> Void) {
        switch UserDefaults.logInType {
        case .facility: DataManager.getFacility(completion: completion)
        case .family: DataManager.getFamily(completion: completion)
        }
    }
    
    static private func getFacility(completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion()
        }
        
        let facilityRef = Firestore.firestore().collection("facilities").document("\(uid)")
        
        facilityRef.getDocument { (document, error) in
            guard let facility = document?.data().flatMap({ Facility(dictionary: $0) }) else {
                return completion()
            }
            
            FacilityEvents.loggedInFacility = facility
            
            for eventId in facility.events {
                let eventRef = Firestore.firestore().collection("events").document(eventId)
                
                eventRef.getDocument { (document, error) in
                    guard let event = document?.data().flatMap({ Event(dictionary: $0) }) else {
                        return
                    }
                    
                    event.isOpen ? FacilityEvents.currentEvents.append(event) : FacilityEvents.pastEvents.append(event)
                    completion()
                }
            }
        }
    }
    
    static private func getFamily(completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion()
        }
        
        let familyRef = Firestore.firestore().collection("users").document("\(uid)")
        
        familyRef.getDocument { (document, error) in
            guard let family = document?.data().flatMap({ Family(dictionary: $0) }) else {
                return completion()
            }
            
            FamilyEvents.loggedInFamily = family
            
            for eventId in family.events {
                let eventRef = Firestore.firestore().collection("events").document(eventId)
                
                eventRef.getDocument { (document, error) in
                    guard let event = document?.data().flatMap({ Event(dictionary: $0) }) else {
                        return
                    }
                    event.isOpen ? FamilyEvents.currentEvents.append(event) : FamilyEvents.pastEvents.append(event)
                    completion()
                }
            }
            
        }
    }
}
