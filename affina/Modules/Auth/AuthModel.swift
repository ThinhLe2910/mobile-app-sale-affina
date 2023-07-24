//
//  AuthModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/07/2022.
//

import Foundation

class LoginRequest: BaseApiRequest {
}

// MARK: Error
enum PasswordError: Int {
    case empty, invalid, incorrect, error, expired, accountBlocked
}

// MARK: Check phone code
enum CheckPhoneCode: String {
    case LOGIN_2001
    case LOGIN_4002 // Account blocked
    case OK_200 = "200"
    case AUTH_4001 // Bad request, validation error
    case EXISTED_5000 = "5000"
}

// MARK: Login Code
enum LoginCode: String {
    case OK_200 = "200"
    case AUTH_4001
    case LOGIN_4000 // Wrong username or password
    case LOGIN_4002 // Account blocked
    case LOGIN_5000 = "5000" // Unknown error from serve
}

// MARK: Check phone response
struct CheckPhoneResponse: Codable {
    let code: String
    let messages: String
}

// MARK: Login model
struct LoginModel: Codable {
    let username: String
    let password: String
    let pushKey: String
    var dictionary: [String: Any] {
        return [
            "username": username,
            "password": password,
            "pushKey": pushKey
        ]
    }
    
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
}

// MARK: User auth response
struct UserAuthResponseData: Codable {
    let expireAt: Double?
    let token: String?
    let refreshAt: Double?
    let profileDetails: ProfileDetails?
}

struct ProfileDetails: Codable {
    let cusName: String
    let companyId: String?
    let decentralizationList: [String]?
}

struct ProfileRegisterModel: Codable {
    let token: String
    let gender: Int
    let name: String
    let dob: Double
    let email: String
    var password: String = ""

    var dictionary: [String: Any] {
        return [
            "token": token,
            "gender": gender,
            "name": name,
            "dob": dob,
            "email": email,
            "password": password
        ]
    }
    
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }

}
