//
//  Memory.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/17/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Memory {
    
    var date: Int
    var image: String?
    var memory: String
    var name: String
    var video: String?
    var videoThumbnail: String?

    
    
    
    var dictionary: [String: Any] {
        return [
            
            "date": date,
            "image": image ?? "",
            "memory": memory,
            "name": name,
            "video": video ?? "",
            "videoThumbnail": videoThumbnail ?? ""
            
        ]
        
    }
    
}


extension Memory: DocumentSerializable {
    
    init?(dictionary: [String: Any]) {
        
        guard let date = dictionary["date"] as? Int,
            let image = dictionary["image"] as? String?,
            let memory = dictionary["memory"] as? String,
            
            let name = dictionary["name"] as? String,
        
            let video = dictionary["video"] as? String?,
        
            let videoThumbnail = dictionary["videoThumbnail"] as? String?
        
            
        else {
                return nil
                
        }
        
        self.init(
            
            date: date,
            image: image,
            memory: memory,
            name: name,
            video: video,
            videoThumbnail: videoThumbnail
            
            
        )
    }
}

