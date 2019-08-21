//
//  FirebaseReference.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 5/14/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

enum DBReference {
    
    case root
    case users(uid: String)
    
    //Mark: - Public
    
    func reference() -> DatabaseReference {
        
        switch self {
        case .root:
            return rootRef
        default:
            return rootRef.child(path)
            
        }
        //return ...
    }
    
    private var rootRef: DatabaseReference {
        
        return Database.database().reference()
        
    }
    
    
    private var path: String {
        switch self {
        case .root:
            return ""
        case .users(let uid):
            return "users/\(uid)"
        }
        
        
    }
    
}
