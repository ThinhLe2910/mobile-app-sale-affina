//
//  JSONAble.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 22/08/2022.
//

import Foundation

protocol JSONAble {}

extension JSONAble {
    func toDict() -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
    
    func toJsonData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: toDict())
    }
    
    func toJSONString() -> String {
        return toJsonData()?.toJSONString() ?? "Error: JSON error"
    }
}

extension Data {
    func toJSONString() -> String {
        return String(data: self, encoding: String.Encoding.utf8) ?? "JSON error"
    }
}
