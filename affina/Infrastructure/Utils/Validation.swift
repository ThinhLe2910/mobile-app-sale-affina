//
//  Validation.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 27/05/2022.
//

import Foundation

class Validation {
    
    static func isEmptyString(string: String?) -> Bool {
        guard let string = string else {
            return true
        }
        return string.isEmpty
    }
    
    static func isValidPhoneNumber(phone: String) -> Bool {
        let regEx = "^[0-9]{10,13}$"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: phone)
    }
    
    static func isValidEmail(email: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Require at least 1 special letter, 1 digital letter, 1 lowercase letter
    static func isValidPassword(password: String) -> Bool {
//        let regEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{6,20}$" // Also validate uppercase letter
        let regEx = "^(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{6,20}$"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isAlphabetCharacter = password.lowercased() == password.replaceFoldingTextWithDD()
        return test.evaluate(with: password) && isAlphabetCharacter
    }
    
    static func isValidFullname(fullName: String) -> Bool {
        let regEx = "^[a-zA-Z0-9 ]{2,60}$"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: fullName.convertToEngLowercase())
    }
    
    static func isValidUsername(string: String) -> Bool {
        let regEx = "^[a-zA-Z0-9@._-]{6,45}$"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: string)
    }
    
    static func isValidIDNumber(string: String) -> Bool {
        let regEx = "^[a-zA-Z0-9]{8,12}$"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: string)
    }
    
    static func isValidAddress(_ string: String) -> Bool {
        let regEx = "^[a-zA-Z0-9 .,-/]{1,120}$"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: string.lowercased().convertToEngLowercase())
    }
    
    static func isValidCMND(_ string: String) -> Bool {
        let regEx = "^[0-9]{9,9}$"
        let regEx2 = "^[0-9]{12,12}$"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        let test2 = NSPredicate(format:"SELF MATCHES %@", regEx2)
        return test.evaluate(with: string) || test2.evaluate(with: string)
    }
    
    static func isValidCCCD(_ string: String) -> Bool {
        let regEx = "^[0-9]{12,12}$"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: string)
    }
    
    static func isValidPassport(_ string: String) -> Bool {
        let regEx = "^[a-zA-Z0-9]{8,8}$"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: string)
    }
}
