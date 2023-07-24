//
//  BaseProtocol.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import Foundation

protocol BaseProtocol: AnyObject {
    func lockUI()
    func unlockUI()
    
    func showError(error: ApiError)
    
    func showAlert()
}
