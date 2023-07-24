//
//  SizeExtension.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import UIKit

extension CGFloat {
    var width: CGFloat {
        return floor(self * UIConstants.Layout.screenWidth) / UIConstants.Layout.screenDesignWidth
    }
    
    var height: CGFloat {
        return floor(self * UIConstants.Layout.screenHeight) / UIConstants.Layout.screenDesignHeight
    }
    
    func addComma(_ comma: String = ".") -> String {
        let arr = Array("\(self)").map({ String($0) })
        var result = ""
        for (index, item) in arr.reversed().enumerated() {
            result += item
            if index % 3 == 2 && index != arr.count - 1 && (index > 0 && Int(arr.reversed()[index - 1]) != nil) {
                result += comma
            }
        }
        
        return Array(result).map({ String($0) }).reversed().joined()
    }
}

extension Int {
    var width: CGFloat {
        return floor(CGFloat(self) * UIConstants.Layout.screenWidth) / UIConstants.Layout.screenDesignWidth
    }
    
    var height: CGFloat {
        return floor(CGFloat(self) * UIConstants.Layout.screenHeight) / UIConstants.Layout.screenDesignHeight
    }
    
    func addComma(_ comma: String = ".") -> String {
        let arr = Array("\(self)").map({ String($0) })
        var result = ""
        for (index, item) in arr.reversed().enumerated() {
            result += item
            if index % 3 == 2 && index != arr.count - 1 && (index < (arr.count - 1) && Int(arr.reversed()[index + 1]) != nil) {
                result += comma
            }
        }
        
        return Array(result).map({ String($0) }).reversed().joined()
    }
}

extension Double {
    var width: CGFloat {
        return floor(CGFloat(self) * UIConstants.Layout.screenWidth) / UIConstants.Layout.screenDesignWidth
    }
    
    var height: CGFloat {
        return floor(CGFloat(self) * UIConstants.Layout.screenHeight) / UIConstants.Layout.screenDesignHeight
    }
    
    func addComma(_ comma: String = ".") -> String {
        let arr = Array("\(self)").map({ String($0) })
        var result = ""
        for (index, item) in arr.reversed().enumerated() {
            result += item
            if index % 3 == 2 && index != arr.count - 1 && (index > 0 && Int(arr.reversed()[index - 1]) != nil) {
                result += comma
            }
        }
        
        return Array(result).map({ String($0) }).reversed().joined()
    }
}

