//
//  BiometryAuth.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import Foundation
import LocalAuthentication

protocol BiometryAuthDelegate: AnyObject {
    func authFail(error: Error?)
    func authSuccessful()
    func deviceNotSupport()
}

class BiometryAuth {
    weak var delegate: BiometryAuthDelegate?
    
    public func authWithBiometry(isLogin: Bool = true) {
        let context = LAContext()
        UIConstants.isUsingBiometry = true
        
        let reason = "Log in to your account"
//        if isLogin {
//            context.localizedFallbackTitle = ""
//            context.localizedCancelTitle = "MANUAL_LOGIN".localize()
//        }
//        else {
//            context.localizedCancelTitle = "FORGOT_BUTTON_CANCEL".localize()
//            context.localizedFallbackTitle = ""
//        }
        
        var error: NSError?
        
        // .deviceOwnerAuthentication allows biometric or passcode authentication
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    DispatchQueue.main.async {
                        UIConstants.isUsingBiometry = false
                        self.delegate?.authSuccessful()
                    }
                }
                else {
                    if let error = error {
                        self.errorMessage(errorCode: error._code)
                    }
                    DispatchQueue.main.async {
                        UIConstants.isUsingBiometry = false
                         self.delegate?.authFail(error: error ?? nil)
                    }
                }
            }
        }
        else {
            if let error = error {
                self.errorMessage(errorCode: error._code)
            }
            DispatchQueue.main.async {
                UIConstants.isUsingBiometry = false
                 self.delegate?.authFail(error: error ?? nil)
            }
        }
    }
    
    private func errorMessage(errorCode: Int) {
        var message = ""
        if #available(iOS 11.0, *) {
            switch errorCode {
            case LAError.authenticationFailed.rawValue:
                message = "Authentication Failed \(LAError.authenticationFailed.rawValue)"
                break
            case LAError.userCancel.rawValue:
                message = "User Cancel \(LAError.userCancel.rawValue)"
                break
            case LAError.appCancel.rawValue:
                message = "App Cancel \(LAError.appCancel.rawValue)"
                break
            case LAError.invalidContext.rawValue:
                message = "Invalid Context \(LAError.invalidContext.rawValue)"
                break
            case LAError.biometryLockout.rawValue:
                message = "Biometry Lockout \(LAError.biometryLockout.rawValue)"
                break
            case LAError.biometryNotEnrolled.rawValue:
                message = "Biometry Not Enrolled \(LAError.biometryNotEnrolled.rawValue)"
                break
            case LAError.biometryNotAvailable.rawValue:
                message = "Biometry Not Available \(LAError.biometryNotAvailable.rawValue)"
                break
            default:
                message = "Some error found \(errorCode)"
            }
        }
        else {
            switch errorCode {
            case LAError.authenticationFailed.rawValue:
                message = "Authentication Failed \(LAError.authenticationFailed.rawValue)"
                break
            case LAError.userCancel.rawValue:
                message = "User Cancel \(LAError.userCancel.rawValue)"
                break
            case LAError.appCancel.rawValue:
                message = "App Cancel \(LAError.appCancel.rawValue)"
                break
            case LAError.invalidContext.rawValue:
                message = "Invalid Context \(LAError.invalidContext.rawValue)"
                break
            default:
                message = "Some error found \(errorCode)"
            }
        }
        Logger.Logs(event: .debug, message: message)
    }
}
