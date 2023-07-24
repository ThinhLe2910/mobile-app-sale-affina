//
//  ForgotPasswordModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 24/05/2022.
//

import Foundation

class ForgotPasswordRequest: BaseApiRequest {
}

// MARK: Code
enum ForgotPasswordCode: String {
    case OK_200 = "200"
    case AUTH_4001
    case PASSWORD_4000 // Token forgot password expired
}

struct ForgotPasswordModel: Encodable {
    let token: String
    let password: String
    
    var dictionary: [String: Any] {
        return [
            "token": token,
            "password": password
        ]
    }
    
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
}
