//
//  EventPopupManager.swift
//  affina
//
//  Created by Intelin MacHD on 24/04/2023.
//

import UIKit

class EventPopupManager {
    static let shared = EventPopupManager()
    private var shownPopup = [String]()
    private init() {}
    
    func getShownPopup() -> [String] {
        shownPopup
    }
    
    func appendToList(id: String) {
        shownPopup.appendIfNotContains(id)
    }
}
