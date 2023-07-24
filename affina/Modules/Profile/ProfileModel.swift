//
//  ProfileModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 30/05/2022.
//

import Foundation

struct ProfileModel: Codable, Equatable {
    let userID: String
    let displayID: String
    
    var name: String
    var license: String?
    var licenseType: Int?
    var licenseFront: String?
    var licenseBack: String?
    var gender: Int
    var dob: Double
    var phone: String
    var email: String?
    var cityCode: Int?
    var districtsCode: Int?
    var wardsCode: Int?
    var address: String?
    let status: Int
    var upload: String?
    var avatar: String?
    var matrimony: Int?
    var blackList: Int?
    let lastLogin: Int?
    let createdAt: Int
    let createdBy: String
    let modifiedAt: Int
    let modifiedBy: String
    let isActiveFlexi: Bool?
    let companyId: String?
    let companyName: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case displayID = "displayId"
        case name, license, licenseFront, licenseBack, gender, dob, phone, email, cityCode, districtsCode, wardsCode, address, matrimony, avatar, status, upload, lastLogin, createdAt, createdBy, modifiedAt, modifiedBy, licenseType, isActiveFlexi
        case companyId, companyName
    }
}

enum ProfileCode: String {
    case OK_200 = "200"
    case AUTH_4001
}

struct RelativeModel: Codable {
    let relativeId: String
    let userId: String
    var name: String
    let license: String
    let imageLicense: String
    let gender: Int
    let dob: Double
    let phone: String
    var email: String
    let address: String
    let relationship: Int
    let createdAt: Double
    let createdBy: String
    let modifiedAt: Double
    let modifiedBy: String
}
