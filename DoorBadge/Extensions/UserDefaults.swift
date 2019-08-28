//
//  UserDefaults.swift
//  DoorBadge
//
//  Created by Seweryn Katolyk on 8/28/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation

extension UserDefaults {
    private enum Key {
        static let logInType = "logInType"
        static let thanksFirst = "thanksFirst"
        static let lastEventSelectedRow = "lastEventSelectedRow"
    }
    
    static var logInType: LogInType {
        get { return LogInType(rawValue: standard.string(forKey: Key.logInType) ?? "") ?? .facility }
        set { standard.set(newValue.rawValue, forKey: Key.logInType) }
    }
    
    static var thanksFirst: Bool {
        get { return standard.bool(forKey: Key.thanksFirst) }
        set { standard.set(newValue, forKey: Key.thanksFirst) }
    }
    
    static var lastEventSelectedRow: Int {
        get { return standard.integer(forKey: Key.lastEventSelectedRow) }
        set { standard.set(newValue, forKey: Key.lastEventSelectedRow) }
    }
}
