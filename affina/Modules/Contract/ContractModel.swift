//
//  ContractModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/06/2022.
//

import Foundation

enum ContractCode: String {
    case OK_200 = "200"
}

enum ContractStatus: Int {
    case active = 1 // Contract approved by employee or customer paid
    case unpaid = 4 // Contract is unpaid
    case paid = 5 // Contract is paid
}

// MARK: - ContractModel
struct ContractModel: Codable {
    let contractID: String
    let contractStatus, contractEndDate: Int
    let listContractObject: [ListContractObject]
    
    enum CodingKeys: String, CodingKey {
        case contractID = "contractId"
        case contractStatus, contractEndDate, listContractObject
    }
}

// MARK: - ListContractObject
struct ListContractObject: Codable {
    let contractObjectIdProvider, contractObjectURL: String?
    let peopleName: String
    let customerType:Int?
    let contractObjectStartDate, contractObjectEndDate: Double?
    let programId: String?
    let companyProvider: String?
    let majorId: String?
    let contractId: String?
    let contractObjectId:String
    
    enum CodingKeys: String, CodingKey {
        case contractObjectIdProvider
        case contractObjectURL = "contractObjectUrl"
        case peopleName
        case customerType
        case contractObjectId
        case contractObjectStartDate, contractObjectEndDate
        case programId, companyProvider, majorId, contractId
    }
}

// MARK: - ContractDetailModel
struct ContractDetailModel: Codable {
    let contractID: String
    let contractStatus, contractEndDate: Int
    let listContractObject: [ListContractDetailObject]
    
    enum CodingKeys: String, CodingKey {
        case contractID = "contractId"
        case contractStatus, contractEndDate, listContractObject
    }
}

// MARK: - ListContractObject
struct ListContractDetailObject: Codable {
    let contractObjectID, contractID: String
    let contractObjectIdProvider, contractObjectURL: String?
    let programTypeName, programTypeID, programID, programName: String
    let packageID, packageName: String
    let contractObjectIDDisplay: String
    let fromAge, toAge, feeMainBenefit: Int
    let termsID: String
    let listExclusionTerms, listParticipationTerms: [ContractSubBenefit]?
    let termsHighlight, termsBenefit, termsApplicableObject, termsFeePaymentMethod: String?
    let majorName, majorID, productID: String?
    let termsHospital: String?
    let codeFromProvider: String?
    let feeInsurance, maximumAmount: Int?
    let companyProviderName, companyProvider, contractObjectType: String?
    let peopleRelationship: Int?
    let peopleName: String?
    let peopleDob, peopleGender: Int
    let peopleLicense, peoplePhone, peopleEmail, peopleAddress: String?
    let listProductMainBenefit: [ContractListProductMainBenefit]
    let listProductSideBenefit: [ContractListProductSideBenefit]?
    let document:String?
    let contractObjectStartDate: Double?
    let contractObjectEndDate: Double?
    
    enum CodingKeys: String, CodingKey {
        case document = "document"
        case contractObjectID = "contractObjectId"
        case contractObjectIdProvider
        case contractObjectIDDisplay = "contractObjectIdDisplay"
        case contractObjectURL = "contractObjectUrl"
        case contractID = "contractId"
        case programTypeName
        case programTypeID = "programTypeId"
        case programID = "programId"
        case programName
        case packageID = "packageId"
        case packageName, fromAge, toAge, feeMainBenefit
        case termsID = "termsId"
        case termsHighlight, termsBenefit, termsApplicableObject, termsFeePaymentMethod, termsHospital, majorName
        case majorID = "majorId"
        case productID = "productId"
        case codeFromProvider, feeInsurance, maximumAmount, companyProviderName, companyProvider, contractObjectType, peopleRelationship, peopleName, peopleDob, peopleGender, peopleLicense, peoplePhone, peopleEmail, peopleAddress, listProductMainBenefit, listProductSideBenefit, listExclusionTerms, listParticipationTerms
        case contractObjectStartDate, contractObjectEndDate
    }
}

//
//// MARK: - ListProductMainBenefit
//struct ListContractProductMainBenefit: Codable {
//    let id, name: String
//    let scope: Int
//    let listMaximumAmountMainBenefit: [ListBenefit]?
//    let listProductSubMainBenefit: [ContractSubBenefit]
//}
//
//// MARK: - ListProductMainBenefit
//struct ListContractProductSideBenefit: Codable {
//    let id: String
//    let name: String
//    let content: String?
//    let scope: Int
//    let applicableGender, fromAge, toAge: Int
//    let listProductSubSideBenefit: [ContractSubBenefit]?
//    let listFeeAndMaximumAmountSideBenefit: [ListBenefit]?
//}


