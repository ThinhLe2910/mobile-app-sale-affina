//
//  RangeExtension.swift
//  affina
//
//  Created by Intelin MacHD on 05/04/2023.
//

import Foundation

extension RangeReplaceableCollection where Element: Equatable {
    mutating func appendIfNotContains(_ element: Element) {
        if firstIndex(of: element) == nil {
            append(element)
        }
    }
}
