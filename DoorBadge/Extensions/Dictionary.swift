//
//  Dictionary.swift
//  
//
//  Created by Severyn-Wsevolod Katolyk on 8/23/19.
//  Copyright © 2019 Severyn-Wsevolod Katolyk. All rights reserved.
//

import Foundation

@dynamicMemberLookup
protocol DictionaryDynamicLookup {
    associatedtype Key
    associatedtype Value
    subscript(key: Key) -> Value? { get }
}

extension DictionaryDynamicLookup where Key == String {
    subscript(dynamicMember member: String) -> Value? {
        return self[member]
    }
}

protocol StringValueLookup: DictionaryDynamicLookup {}

extension StringValueLookup where Key == String {
    subscript(stringFor key: Key) -> String? {
        return self[key] as? String
    }
}

protocol BoolValueLookup: DictionaryDynamicLookup {}

extension BoolValueLookup where Key == String {
    subscript(boolFor key: Key) -> Bool? {
        return self[key] as? Bool
    }
}

protocol IntValueLookup: DictionaryDynamicLookup {}

extension IntValueLookup where Key == String {
    subscript(intFor key: Key) -> Int? {
        return self[key] as? Int
    }
}

extension Dictionary: IntValueLookup {}
extension Dictionary: BoolValueLookup {}
extension Dictionary: StringValueLookup {}
