//
//  EventGifts.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/27/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit


struct EventGifts {
    
    static var gifts : [Gift] = []
    
    
    static func append(gift: Gift)
    {
        if !EventGifts.gifts.contains(where: {$0.giftId == gift.giftId}) {
            EventGifts.gifts.append(gift)
            
        }
    }
    
}
