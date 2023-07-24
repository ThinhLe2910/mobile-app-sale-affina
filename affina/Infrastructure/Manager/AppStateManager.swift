//
//  AppStateManager.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/01/2023.
//

import Foundation

class AppStateManager {
    static let shared = AppStateManager()
    private init() { }
    
    var isOpeningNotification: Bool = false
    var isOpeningNotificationDetail: Bool = false
    
    var currentTabBar: Int = 0
    
    var hasUnReadNoti: Bool = false
    var profile: ProfileModel?
    
    var userCoin: Double = 0
    var flexiSummary: FlexiSummaryModel?
}
