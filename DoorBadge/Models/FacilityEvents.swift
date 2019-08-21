//
//  FacilityEvents.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/14/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit


struct FacilityEvents {
    
    static var currentEvents : [Event] = []
    static var pastEvents : [Event] = []
    static var loggedInFacility : Facility?

    static func append(event : Event)
    {
        if !FacilityEvents.currentEvents.contains(where: {$0.eventId == event.eventId}) {
            FacilityEvents.currentEvents.append(event)
            
        }
    }
   
}
