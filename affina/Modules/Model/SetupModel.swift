//
//  SetupModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 14/12/2022.
//

import UIKit

enum CardStatus: Int {
    case Prepare = 0
    case Available
    case Unavailabel
}

enum CardType: Int {
    case Affina = 1
    case Provider = 2
}

enum CardStatusFilter: Int {
    case UPCOMING = 0
    case HAPPENING = 1
    case FINISHED = 2
}

enum CardFieldFontEnum: Int {
    case TimesNewRoman = 0
    case Arial = 1
    case Calibri = 2
    
    var font: String {
        switch self {
        case .TimesNewRoman:
            return "TimesNewRoman"
        case .Arial:
            return "Arial"
        case .Calibri:
            return "Calibri"
        }
    }
}

enum CardFieldTypeEnum: Int {
    case Fixed = 0
    case Variable = 1
}

enum CardFieldVariableEnum: Int {
    case PeopleName = 1
    case ContractObjectIdProvider = 2
    case CardNumber = 3
    case PeopleDob = 4
    case ContractObjectStartDate = 5
    case ContractObjectEndDate = 6
    case BuyerName = 7
    case ProgramName = 8
    case CompanyProviderName = 9
    case MaximumAmount = 10
    case PeopleLicense = 11
}

// MARK: - SetupModel
struct SetupModel: Codable {
    let listLogo: [ListSetupLogo]?
    let listBanner: [ListSetupBanner]?
    let listImageClaim: [ListSetupImageClaim]?
    let listCoverImageProgram: [ListSetupCoverImageProgram]?
    let listIconBenefit: [ListSetupIconBenefit]?
    let listGroupProgram: [ListSetupGroupProgram]?
    let listIconFlexi: [ListSetupIconFlexi]?
    let listCard: [ListSetupCard]?
    let listFormClaim: [ListSetupFormClaim]?
}

// MARK: - ListSetupLogo
struct ListSetupLogo: Codable {
    let companyID, logo: String?

    enum CodingKeys: String, CodingKey {
        case companyID = "companyId"
        case logo
    }
}

// MARK: - ListSetupBanner
struct ListSetupBanner: Codable {
    let banner, link: String?
}

// MARK: - ListSetupCoverImageProgram
struct ListSetupCoverImageProgram: Codable {
    let majorID, programTypeID, companyID, programID: String?
    let imageFilter, imageDetail, imageOutstanding: String?

    enum CodingKeys: String, CodingKey {
        case majorID = "majorId"
        case programTypeID = "programTypeId"
        case companyID = "companyId"
        case programID = "programId"
        case imageFilter, imageDetail, imageOutstanding
    }
}

// MARK: - ListSetupGroupProgram
struct ListSetupGroupProgram: Codable {
    let groupName, background, content, icon: String?
}

// MARK: - ListSetupIconBenefit
struct ListSetupIconBenefit: Codable {
    let id, icon: String?
    let listBenefit: [ListSetupBenefit]?
}

// MARK: - ListSetupBenefit
struct ListSetupBenefit: Codable {
    let benefitID: String?
    let benefitType: Int?

    enum CodingKeys: String, CodingKey {
        case benefitID = "benefitId"
        case benefitType
    }
}

// MARK: - ListSetupIconFlexi
struct ListSetupIconFlexi: Codable {
    let name, icon: String?
}

// MARK: - ListImageClaim
struct ListSetupImageClaim: Codable {
    let id, majorID, programTypeID: String?
    let claimType: Int?
    let listImageClaimDetail: [ListSetupImageClaimDetail]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case majorID = "majorId"
        case programTypeID = "programTypeId"
        case claimType, listImageClaimDetail
    }
}

// MARK: - ListSetupImageClaimDetail
struct ListSetupImageClaimDetail: Codable {
    let imageClaimID: String?
    let orderImage, requireImage: Int?
    let name, content, image, file: String?
    let textButtonSkip: String?
    
    enum CodingKeys: String, CodingKey {
        case imageClaimID = "imageClaimId"
        case orderImage, requireImage, name, content, image, file
        case textButtonSkip
    }
}

// MARK: - ListSetupCard
struct ListSetupCard: Codable {
    let id, majorID, programTypeID, companyID: String?
    let programID: String?
    let type: Int?
    let startTime, endTime: Double?
    let listCardOrder: [ListSetupCardOrder]?

    enum CodingKeys: String, CodingKey {
        case id
        case majorID = "majorId"
        case programTypeID = "programTypeId"
        case companyID = "companyId"
        case programID = "programId"
        case startTime, type, listCardOrder
        case endTime
    }
}

// MARK: - ListSetupCardOrder
struct ListSetupCardOrder: Codable {
    let id, cardID: String?
    let orderCard: Int?
    let background: String?
    let listCardOrderField: [ListSetupCardOrderField]?

    enum CodingKeys: String, CodingKey {
        case id
        case cardID = "cardId"
        case orderCard, background, listCardOrderField
    }
}

// MARK: - ListSetupCardOrderField
struct ListSetupCardOrderField: Codable {
    let cardOrderID: String?
    let fieldType: Int?
    let fieldFixedName: String?
    let fieldVariable: Int?
    let ox, oy: CGFloat?
    let size: Int?
    let font: Int?
    let color: String?

    enum CodingKeys: String, CodingKey {
        case cardOrderID = "cardOrderId"
        case fieldType, fieldFixedName, fieldVariable, ox, oy, size, font, color
    }
}

// MARK: ListSetupFormClaim
struct ListSetupFormClaim: Codable {
    let majorId: String?
    let programTypeId: String?
    let companyId: String?
    let programId: String?
    let title: String?
    let file: String?
    
    enum CodingKeys: String, CodingKey {
        case majorId = "majorId"
        case programTypeId = "programTypeId"
        case companyId = "companyId"
        case programId = "programId"
        case title, file
    }
}

