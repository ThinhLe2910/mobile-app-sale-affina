//
//  PopupManager.swift
//  affina
//
//  Created by Intelin MacHD on 26/08/2022.
//

import UIKit

class PopupManager: PriorityQueueDelegate {
    
    static let shared = PopupManager()
    
    private var popupQueue = PriorityQueue()
    
    private var currentlyServing: PriorityNode? = nil
    
    private let popupDispatchQueue = DispatchQueue(label: "Popup Queue")
    
    static var isShowingPopup: Bool = false
    
    private init() {
        popupQueue.delegate = self
    }
    
    func queueStartExecuting() {
        showPopup()
    }
    
    func queueEndExecuting() {
        Logger.Logs(message: "End executing")
    }
    
    func showPopup() {
        print("Showing")
        popupDispatchQueue.async { [self] in
            if currentlyServing == nil {
                if let popup = popupQueue.dequeue() {
                    PopupManager.isShowingPopup = true
                    Logger.Logs(message: "Now showing " + popup.getName())
                    self.currentlyServing = popup
                    DispatchQueue.main.async {
                        if let currentVC = UIApplication.topViewController() {
                            DispatchQueue.main.async {
                                currentVC.view.addSubview(popup.popup)
                                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) {
                                    //                        popup.popup.alpha = 1
                                    popup.popup.isHidden = false
                                    popup.popup.layer.opacity = 1
                                } completion: { _ in
                                    popup.showedCallBack?()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removePopup() {
        popupDispatchQueue.async {
            guard self.currentlyServing != nil else {
                self.currentlyServing?.popup.removeFromSuperview()
                return
            }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) { [self] in
                    //            currentlyServing!.popup.alpha = 0
                    currentlyServing?.popup.isHidden = true
                    currentlyServing?.popup.layer.opacity = 0
                } completion: { [self] _ in
                    PopupManager.isShowingPopup = false
                    currentlyServing?.popup.removeFromSuperview()
                    Logger.Logs(message: "Removing \(currentlyServing?.getName() ?? "")")
                    currentlyServing = nil
                    removePopup(of: currentlyServing?.name ?? "")
                    showPopup()
                }
            }
        }
    }
    
    func getPopup(_ name: String) -> PriorityNode?{
        return popupQueue.getNode(of: name)
    }
    
    func updatePriority(of name: String, priority: PopupPriority) {
        if var node = popupQueue.getNode(of: name) {
            node.priority = priority
            popupQueue.updateNode(of: name, with: node)
        }
    }
    
    func removePopup(of name: String) {
        PopupManager.isShowingPopup = false
        for item in popupQueue.topPriorityItems {
            if item.getName() == name {
                item.popup.removeFromSuperview()
            }
        }
        for item in popupQueue.highPriorityItems {
            if item.getName() == name {
                item.popup.removeFromSuperview()
            }
        }
        for item in popupQueue.normalPriorityItems {
            if item.getName() == name {
                item.popup.removeFromSuperview()
            }
        }
        popupQueue.removeNode(of: name)
    }
    
    func queuePopup(_ node: PriorityNode) {
        popupQueue.enqueue(node)
    }
    
}
