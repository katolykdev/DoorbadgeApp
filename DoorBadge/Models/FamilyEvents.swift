//
//  FamilyEvents.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 6/12/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit


struct FamilyEvents {
    
    static var currentEvents : [Event] = []
    static var pastEvents : [Event] = []
    static var loggedInFamily : Family?
    
    static func append(event : Event)
    {
        if !FamilyEvents.currentEvents.contains(where: {$0.eventId == event.eventId}) {
            FamilyEvents.currentEvents.append(event)
            
        }
    }
    
}

