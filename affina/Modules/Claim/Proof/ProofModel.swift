//
//  ProofModel.swift
//  affina
//
//  Created by Dylan on 27/09/2022.
//

import Foundation

enum ClaimProcessType: Int {
    case PROCESSING = 0,
    SENT_INFO = 1,
    REQUIRE_UPDATE = 2,
    REJECT = 3,
    APPROVED = 4
    var string: String {
        switch rawValue {
            case ClaimProcessType.PROCESSING.rawValue:
                return "PROCESSING".localize()
            case ClaimProcessType.SENT_INFO.rawValue:
            return "SENT_INFORMATION".localize()
            case ClaimProcessType.REQUIRE_UPDATE.rawValue:
                return "REQUEST_ADDITIONAL_INFORMATION".localize()
            case ClaimProcessType.REJECT.rawValue:
                return "DECLINE".localize()
            case ClaimProcessType.APPROVED.rawValue:
                return "APPROVED".localize()
            default: return ""
        }
    }
}

enum ClaimType: Int {
    case LABOR_ACCIDENT = 1,
    TRAFFIC_ACCIDENT = 2,
    OUTPATIENT = 3,
    INPATIENT = 4,
    DENTISTRY = 5,
    HOSPITALIZATION_ALLOWANCE = 6,
    INCOME_SUPPORT = 7,
    MATERNITY = 8,
    DEAD = 9,
    ILLNESS = 10,
         SUBSIDY_FOR_HOSPITAL_FEE_INCOME = 11,
         DEATH_BY_ACCIDENT_ILLNESS = 12
    
    var string: String {
        switch rawValue {
            case ClaimType.LABOR_ACCIDENT.rawValue:
                return "ACCIDENT".localize()
            case ClaimType.TRAFFIC_ACCIDENT.rawValue:
                return "TRAFFIC_ACCIDENT".localize()
            case ClaimType.OUTPATIENT.rawValue:
                return "OUTPATIENT".localize()
            case ClaimType.INPATIENT.rawValue:
                return "INPATIENT".localize()
            case ClaimType.DENTISTRY.rawValue:
                return "DENTAL".localize()
            case ClaimType.HOSPITALIZATION_ALLOWANCE.rawValue:
                return "HOSPITALIZATION_ALLOWANCE".localize()
            case ClaimType.INCOME_SUPPORT.rawValue:
                return "INCOME_SUPPORT".localize()
            case ClaimType.MATERNITY.rawValue:
                return "MARTENITY".localize()
            case ClaimType.DEAD.rawValue:
                return "DEATH_BY_ACCIDENT_ILLNESS".localize()
            case ClaimType.ILLNESS.rawValue :
                return "ILLNESS".localize()
        case ClaimType.SUBSIDY_FOR_HOSPITAL_FEE_INCOME.rawValue :
            return "SUBSIDY_FOR_HOSPITAL_FEE_INCOME".localize()
        case ClaimType.DEATH_BY_ACCIDENT_ILLNESS.rawValue :
            return "DEATH_BY_ACCIDENT_ILLNESS".localize()
            default: return ""
        }
    }
}

struct ClaimRequestModel {
    var contractObjectId: String?
    var amountClaim: Int?
    var bankId: String?
    var bankCode: String?
    var bankBranch: String?
    var bankName: String?
    var accountName: String?
    var accountNumberBank: String?
    var relationship: Int?
    var claimType: ClaimType?
    var hospitalizedDate: Double?
    var hospitalDischargeDate: Double?
    var placeOfTreatment: String?
    var diagnostic: String?
    var upload: String? // images
    
    var name: String?
    var phone: String?
    var email: String?
    
    var dict: [String: Any?] {
        return [
            "contractObjectId": contractObjectId,
            "amountClaim": amountClaim ?? 0,
            "bankCode": bankCode,
            "bankName": bankName,
            "bankId": bankId,
            "bankBranch": bankBranch,
            "accountName": accountName,
            "accountNumberBank": accountNumberBank,
            "relationship": relationship ?? 0,
            "claimType": claimType?.rawValue ?? 0,
            "hospitalizedDate": hospitalizedDate ?? 0,
            "hospitalDischargeDate": hospitalDischargeDate ?? 0,
            "placeOfTreatment": placeOfTreatment,
            "diagnostic": diagnostic,
            "upload": upload,
            "name": name,
            "phone": phone,
            "email": email
        ]
    }
}

struct ClaimHistoryModel: Codable {
    let id: String
    let amountClaim: Int?
    let claimType: Int
    let placeOfTreatment: String?
    let status, createdAt: Int
}

struct ClaimDetailModel: Codable {
    let claimType: Int
    let contractObjectID, placeOfTreatment, id, contractID: String
    let hospitalDischargeDate: Int
    let modifiedBy: String
    let amountClaim, modifiedAt: Int
    let createdBy: String
    let upload: String?
    let createdAt, hospitalizedDate: Int
    let diagnostic: String
    let status: Int
    let bankId: String?
    let bankName: String?
    let accountName: String?
    let bankBranch: String?
    let bankCode: String?
    let accountNumberBank: String?
    
    let requireUpdateStatus: Int?
    
    let additionalDocument: String?
    let paperDocument: String?
    
    let benefitCost: String?
    let groupCost: String?
    
    let relationship: Int?
    let majorId: String?
    let programTypeId: String?
    let companyId: String?
    let programId: String
    
    enum CodingKeys: String, CodingKey {
        case amountClaim, accountNumberBank, bankCode, id, hospitalDischargeDate, diagnostic, upload, modifiedAt, hospitalizedDate, placeOfTreatment, bankName, accountName
        case contractID = "contractId"
        case createdBy, relationship, claimType, bankBranch, modifiedBy
        case contractObjectID = "contractObjectId"
        case createdAt, status, bankId, additionalDocument, benefitCost, groupCost
        case requireUpdateStatus
        case paperDocument
        case majorId, programTypeId, programId, companyId
    }
}

