//
//  CardModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 24/08/2022.
//

import Foundation

// MARK: - DataClass
struct CardModel: Codable, Equatable {
    let contractObjectIdProvider: String?
    let cardNumber: String?
    let termsHospital: String?
    
    let customerType: Int?
    
    let contractObjectId: String
    let contractId: String
    let programName: String
    let maximumAmount: Int
    let contractEndDate: Int
    let createdAt: Double
    let peopleLicense: String?
    let peopleName: String
    let peopleDob: Double?
    
    let majorId: String?
    let programTypeId: String?
    
    let companyProvider: String?
    let companyProviderName: String?
    let programId: String?
    let name: String?
    
    let contractObjectIDDisplay: String
    let contractObjectStartDate: Double
    let contractObjectEndDate: Double
    
    let activeBenefits : [String]?
    
    enum CodingKeys: String, CodingKey {
        case contractId
        case customerType, contractEndDate, createdAt
        case contractObjectId
        case contractObjectIDDisplay = "contractObjectIdDisplay"
        case contractObjectIdProvider
        case programTypeId
        case programName, termsHospital
        case majorId
        case maximumAmount, peopleName, peopleDob, cardNumber
        case contractObjectStartDate, contractObjectEndDate
        case companyProviderName
        case companyProvider, programId
        case name
        case peopleLicense
        case activeBenefits
    }
}

struct HospitalModel: Codable {
    let id: String
    let name, address: String?
    let phone: String?
    let createdAt: Int
    let email: String?
    let cityCode: Int?
    let districtsCode: Int?
    let wardsCode: Int?
    let street: String?
    let houseNumber: String?
    let specializing: String?
    let timeserving: String?
}

enum HospitalProviderType: Int {
    case GUARANTEE = 1,
         BLACKLIST = 2
}

enum CustomerType: Int {
    case INDIVIDUAL = 1, GROUP = 2, SME = 3
}
