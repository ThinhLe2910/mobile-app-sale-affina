//
//  PopupQueue.swift
//  affina
//
//  Created by Intelin MacHD on 26/08/2022.
//

import Foundation
import UIKit

enum PopupPriority: Int {
    case normal = 0, high, topPriority
}

struct PriorityNode {
    let name: String
    var priority: PopupPriority = .normal
    let popup: UIView
    
    var showedCallBack: (() -> Void)? = nil
    
    mutating func setPriority(_ newPriority: PopupPriority) {
        priority = newPriority
    }
    
    func getName() -> String {
        return name
    }
}

protocol PriorityQueueDelegate {
    func queueStartExecuting()
    func queueEndExecuting()
}

struct PriorityQueue {
    var topPriorityItems: [PriorityNode] = [] {
        didSet {
            checkQueueChange()
        }
    }
    var highPriorityItems: [PriorityNode] = [] {
        didSet {
            checkQueueChange()
        }
    }
    var normalPriorityItems: [PriorityNode] = [] {
        didSet {
            checkQueueChange()
        }
    }
    
    var delegate: PriorityQueueDelegate?
    
    mutating func enqueue(_ value: PriorityNode) {
        
        for item in topPriorityItems {
            if item.name == value.name {
                return 
            }
        }
        if let _ = topPriorityItems.first(where: {$0.name == value.name}) { return }
        if let _ = highPriorityItems.first(where: {$0.name == value.name}) { return }
        if let _ = normalPriorityItems.first(where: {$0.name == value.name}) { return }
        
        switch value.priority {
            case .topPriority:
                topPriorityItems.append(value)
                break
                
            case .high:
                highPriorityItems.append(value)
                break
                
            case .normal:
                normalPriorityItems.append(value)
                break
        }
        
    }
    
    func checkQueueChange() {
        if topPriorityItems.count + highPriorityItems.count + normalPriorityItems.count > 0 {
            delegate?.queueStartExecuting()
        } else {
            delegate?.queueEndExecuting()
        }
    }
    
    mutating func dequeue() -> PriorityNode?{
        var node: PriorityNode? = nil
        if topPriorityItems.count > 0 {
            node = topPriorityItems.removeFirst()
        }
        
        if highPriorityItems.count > 0 {
            node = highPriorityItems.removeFirst()
        }
        
        if normalPriorityItems.count > 0 {
            node = normalPriorityItems.removeFirst()
        }
        return node
    }
    
    var head: PriorityNode? {
        if topPriorityItems.count > 0 {
            return topPriorityItems.first
        }
        
        if highPriorityItems.count > 0 {
            return highPriorityItems.first
        }
        
        if normalPriorityItems.count > 0 {
            return normalPriorityItems.first
        }
        
        return nil
    }
    
    func getNode(of name: String) -> PriorityNode?{
        if let result = topPriorityItems.first(where: {$0.name == name}) {
            return result
        }
        
        if let result = highPriorityItems.first(where: {$0.name == name}) {
            return result
        }
        
        if let result = normalPriorityItems.first(where: {$0.name == name}) {
            return result
        }
        
        return nil
    }
    
    mutating func updateNode(of name: String, with node: PriorityNode) {
        if let index = topPriorityItems.firstIndex(where: {$0.name == name}) {
            topPriorityItems.remove(at: index)
        }
        
        if let index = highPriorityItems.firstIndex(where: {$0.name == name}) {
            highPriorityItems.remove(at: index)
        }
        
        if let index = normalPriorityItems.firstIndex(where: {$0.name == name}) {
            normalPriorityItems.remove(at: index)
        }
        
        self.enqueue(node)
    }
    
    mutating func removeNode(of name: String) {
        if let index = topPriorityItems.firstIndex(where: {$0.name == name}) {
            topPriorityItems.remove(at: index)
            topPriorityItems = topPriorityItems.filter({$0.name != name})
            return
        }
        
        if let index = highPriorityItems.firstIndex(where: {$0.name == name}) {
            highPriorityItems.remove(at: index)
            highPriorityItems = highPriorityItems.filter({$0.name != name})
            return
        }
        
        if let index = normalPriorityItems.firstIndex(where: {$0.name == name}) {
            normalPriorityItems.remove(at: index)
            normalPriorityItems = normalPriorityItems.filter({$0.name != name})
            return
        }
    }
}
