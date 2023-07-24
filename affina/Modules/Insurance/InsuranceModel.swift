//
//  InsuranceModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 10/08/2022.
//

import Foundation

// Enum
enum BuyHelpEnum: Int {
    case YES = 1
    case NO = 0
}

enum RedBillEnum: Int {
    case YES = 1
    case NO = 0
}

enum ContractPeriod: Int {
    case LIFETIME = 0
    case YEAR = 1
    case MONTH = 2
    case DAY = 5
    
    func toString() -> String {
        switch self {
            case .LIFETIME:
                return "LIFETIME".localize()
            case .YEAR:
                return "YEAR".localize()
            case .MONTH:
                return "MONTH".localize()
            case .DAY:
                return "DAY".localize()
        }
    }
}

enum ContractObjectPeopleRelationshipEnum: Int {
    case SELF = 0
    case PARENTS
    case COUPLE
    case SIBLINGS
    case CHILDREN
    case OTHER
    
    var value: String {
        switch self {
            case .SELF:
                return "APPLICANT".localize()
            case .PARENTS:
                return "PARENTS".localize()
            case .COUPLE:
                return "COUPLE".localize()
            case .SIBLINGS:
                return "SIBLINGS".localize()
            case .CHILDREN:
                return "CHILDREN".localize()
            case .OTHER:
                return "OTHER".localize()
        }
    }
}
struct ProgramType: Codable {
    let id: String
    let majorId: String
    let name: String
    let type: Int
}

struct CompanyProvider: Codable {
    let id: String
    let name: String
    let acronymName: String?
    let numberPackage: Int
    let createdAt: Double?
}

struct FilterInsuranceModel: Codable {
    var id: String?
    var fee: Int?
    let limit: Int
    var programTypeId: String
    var dob: Double
    var fromAmount: Int
    var toAmount: Int
    var listProviderId: [String]? // null neu k chon nha bao hiem
    var companyId: String // referal, default la 200001000
    
    var gender: Int? = 1
    
    var dictionary: [String: Any?] {
        return [
            "id": id,
            "fee": fee,
            "limit": limit,
            "programTypeId": programTypeId,
            "dob": dob,
            "fromAmount": fromAmount,
            "toAmount": toAmount,
            "listProviderId": listProviderId,
            "companyId": companyId
        ]
    }
    
    
}

struct FilterProductModel: Codable {
    let id: String
    let programId: String
    let programName: String
    let packageId: String
    let packageName: String
    let highlight: String?
    let fee: Int
    let maximumAmount: Int?
    let companyId: String?
}

// MARK: ProductDetail
struct ProductDetailModel: Codable {
    let id, programID, programName, packageID: String
    let packageName, companyID, majorID, majorName: String
    let programTypeID, programTypeName, codeFromProvider: String
    let fromAge, toAge: Int
    var listProductMainBenefit: [ListProductMainBenefit]
    let listProductSideBenefit: [ListProductSideBenefit]
    let constraintFromAge, constraintToAge, constraintNumber: Int?
    let constraintListRelationship: [Int]
    let listFeeInsurance: [ListFeeInsurance]
    let listProductInProgram: [ListProductInProgram]
    
    enum CodingKeys: String, CodingKey {
        case id
        case programID = "programId"
        case programName
        case packageID = "packageId"
        case packageName
        case companyID = "companyId"
        case majorID = "majorId"
        case majorName
        case programTypeID = "programTypeId"
        case programTypeName, codeFromProvider, fromAge, toAge, listFeeInsurance, listProductMainBenefit, listProductSideBenefit, constraintFromAge, constraintToAge, constraintNumber, constraintListRelationship, listProductInProgram
    }
}

// MARK: - ListFeeInsurance
struct ListFeeInsurance: Codable {
    let productID: String
    let periodType, periodValue, fee: Int
    
    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case periodType, periodValue, fee
    }
}

struct ListProductInProgram: Codable {
    let id, packageName: String
}

struct ListProductMainBenefit: Codable {
    let id, productID, mainBenefitID, name: String
    let scope: Int?
    let listMaximumAmountMainBenefit: [ListMaximumAmountBenefit]
    let listProductSubMainBenefit: [ListProductSubBenefit]?
    let content: String?
    enum CodingKeys: String, CodingKey {
        case id
        case productID = "productId"
        case mainBenefitID = "mainBenefitId"
        case name, scope, listMaximumAmountMainBenefit, listProductSubMainBenefit
        case content
    }
}

//// MARK: - ListMaximumAmountMainBenefit
//struct ListMaximumAmountMainBenefit: Codable {
//    let productMainBenefitID: String?
//    let periodType, periodValue, maximumAmount: Int
//    let productSubMainBenefitID: String?
//
//    enum CodingKeys: String, CodingKey {
//        case productMainBenefitID = "productMainBenefitId"
//        case periodType, periodValue, maximumAmount
//        case productSubMainBenefitID = "productSubMainBenefitId"
//    }
//}

// MARK: - ListMaximumAmountBenefit
struct ListMaximumAmountBenefit: Codable {
    let maximumAmount, periodValue: Int
    let productMainBenefitID: String?
    let periodType: Int
    let productSubSideBenefitID: String?
    
    enum CodingKeys: String, CodingKey {
        case maximumAmount, periodValue
        case productMainBenefitID = "productMainBenefitId"
        case periodType
        case productSubSideBenefitID = "productSubSideBenefitId"
    }
}

struct ListProductSubBenefit: Codable {
    let id: String
    let productMainBenefitID, subMainBenefitID: String?
    let name, content: String
    
    let listMaximumAmountSubMainBenefit: [ListMaximumAmountBenefit]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case productMainBenefitID = "productMainBenefitId"
        case subMainBenefitID = "subMainBenefitId"
        case name, content, listMaximumAmountSubMainBenefit
    }
}

struct ListProductSideBenefit: Codable {
    let id, productID, sideBenefitID, name: String
    let content: String?
    let scope: Int?
    let listFeeAndMaximumAmountSideBenefit: [ListFeeAndMaximumAmountSideBenefit]
    let applicableGender, fromAge, toAge: Int
    let listProductSubSideBenefit: [ListProductSubSideBenefit]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case productID = "productId"
        case sideBenefitID = "sideBenefitId"
        case name, content, scope, listFeeAndMaximumAmountSideBenefit, applicableGender, fromAge, toAge, listProductSubSideBenefit
    }
}

// MARK: - ListProductSubSideBenefit
struct ListProductSubSideBenefit: Codable {
    let subSideBenefitID, productSideBenefitID: String
    let content: String?
    let listMaximumAmountSubSideBenefit: [ListMaximumAmountBenefit]?
    let id, name: String
    
    enum CodingKeys: String, CodingKey {
        case subSideBenefitID = "subSideBenefitId"
        case content
        case productSideBenefitID = "productSideBenefitId"
        case listMaximumAmountSubSideBenefit, id, name
    }
}

// MARK: - ListFeeAndMaximumAmountSideBenefit
struct ListFeeAndMaximumAmountSideBenefit: Codable {
    let productSideBenefitID: String
    let periodType, periodValue, fee, maximumAmount: Int
    
    enum CodingKeys: String, CodingKey {
        case productSideBenefitID = "productSideBenefitId"
        case periodType, periodValue, fee, maximumAmount
    }
}

struct PaymentContractRequestModel: Codable {
    var contractId: String
    var startDate: Double?
    var voucherCode: String? // null nếu không có voucher
    var redBill: Int? // map with enum RedBillEnum
    var redBillCompanyName: String? // null nếu rebBill là 0
    var redBillCompanyAddress: String? // null nếu rebBill là 0
    var redBillCompanyTaxNumber: String? // null nếu rebBill là 0
    var paymentMethod: Int?
    var dictionary: [String: Any?] {
        return [
            "contractId": contractId,
            "startDate": startDate,
            "voucherCode": voucherCode,
            "redBill": redBill,
            "redBillCompanyName": redBillCompanyName,
            "redBillCompanyAddress": redBillCompanyAddress,
            "redBillCompanyTaxNumber": redBillCompanyTaxNumber,
            "paymentMethod": paymentMethod
        ]
    }
}

struct PaymentContractPeopleInfoRequestModel: Codable {
    var productId: String
    var listProductSideBenefit: [String]?
    var period: Int
    var periodValue: Int
    var gender: Int
    var name: String?
    var dob: Double
    var phone: String?
    var email: String?
    var cityCode: Int?
    var districtsCode: Int?
    var wardsCode: Int?
    var address: String?
    var houseNumber: String?
    var street: String?
    var license: String?
    var licenseType: Int?
    var licenseFront: String?
    var licenseBack: String?
    var buyHelp: Int?
    var buyHelpRelationship: Int? //null nếu buyHelp là 0 map with enum  ContractObjectPeopleRelationshipEnum
    var buyHelpName: String? // //null nếu buyHelp là 0
    var buyHelpDob: Double? //null nếu buyHelp là 0
    var buyHelpGender: Int? //null nếu buyHelp là 0
    var buyHelpPhone: String? // //null nếu buyHelp là 0
    var buyHelpEmail: String? // //null nếu buyHelp là 0
    var buyHelpCityCode: Int? //null nếu buyHelp là 0
    var buyHelpDistrictsCode: Int? //null nếu buyHelp là 0
    var buyHelpWardsCode: Int? //null nếu buyHelp là 0
    var buyHelpStreet: String? // //null nếu buyHelp là 0
    var buyHelpHouseNumber: String? // //null nếu buyHelp là 0
    var buyHelpAddress: String? // //null nếu buyHelp là 0
    var buyHelpLicense: String? // //null nếu buyHelp là 0
    var buyHelpLicenseFront: String? // //null nếu buyHelp là 0
    var buyHelpLicenseBack: String? // //null nếu buyHelp là 0
    var buyHelpLicenseType: Int? //null nếu buyHelp là 0
    
    var referralCode: String?
    var pushKey: String?
    
    var dictionary: [String: Any?] {
        return [
            "productId": productId,
            "listProductSideBenefit": listProductSideBenefit,
            "period": period,
            "periodValue": periodValue,
            "buyHelp": buyHelp,
            "gender": gender,
            "name": name,
            "dob": dob,
            "phone": phone,
            "email": email,
            "cityCode": cityCode,
            "districtsCode": districtsCode,
            "wardsCode": wardsCode,
            "address": address,
            "houseNumber": houseNumber,
            "street": street,
            "license": license,
            "licenseType": licenseType,
            "licenseFront": licenseFront,
            "licenseBack": licenseBack,
            "buyHelpName": buyHelpName,
            "buyHelpDob": buyHelpDob,
            "buyHelpRelationship": buyHelpRelationship,
            "buyHelpGender": buyHelpGender,
            "buyHelpPhone": buyHelpPhone,
            "buyHelpEmail": buyHelpEmail,
            "buyHelpCityCode": buyHelpCityCode,
            "buyHelpDistrictsCode": buyHelpDistrictsCode,
            "buyHelpWardsCode": buyHelpWardsCode,
            "buyHelpStreet": buyHelpStreet,
            "buyHelpHouseNumber": buyHelpHouseNumber,
            "buyHelpAddress": buyHelpAddress,
            "buyHelpLicense": buyHelpLicense,
            "buyHelpLicenseFront": buyHelpLicenseFront,
            "buyHelpLicenseBack": buyHelpLicenseBack,
            "buyHelpLicenseType": buyHelpLicenseType,
            "referralCode": referralCode,
            "pushKey": pushKey
        ]
    }
}

// MARK: - InsuranceContractModel
struct InsuranceContractModel: Codable, JSONAble {
    let contractID, buyName, buyPhone, buyAddress: String
    let buyEmail, name: String
    let dob: Int
    let productID, programID, programName, packageID: String
    let packageName: String
    let listProductMainBenefit: [ContractListProductMainBenefit]
    let listProductSideBenefit: [ContractListProductSideBenefit]
    let maximumAmount, feeInsurance, period, periodValue: Int
    let amountPay: Int
    let tokenRegister: String?
    let startDate, endDate: Int?
    let payooOrder, payooChecksum: String?
    let baoKimPaymentURL: String?
    let smartPayUrl: String?
    let redirectUrl: String?
    let transactionId: String?
    
    enum CodingKeys: String, CodingKey {
        case contractID = "contractId"
        case buyName, buyPhone, buyAddress, buyEmail, name, dob
        case productID = "productId"
        case programID = "programId"
        case programName
        case packageID = "packageId"
        case packageName, listProductMainBenefit, listProductSideBenefit, maximumAmount, feeInsurance, period, periodValue, amountPay, tokenRegister, startDate, endDate, payooOrder, payooChecksum
        case baoKimPaymentURL = "baoKimPaymentUrl"
        case smartPayUrl
        case redirectUrl
        case transactionId
    }
}

// MARK: - ContractListProductMainBenefit
struct ContractListProductMainBenefit: Codable {
    let id, name: String
    let scope: String
    let content: String?
    let mainBenefitId: String?
    let listMaximumAmountMainBenefit: [ListBenefit]
    let listProductSubMainBenefit: [ContractSubBenefit]?
}

// MARK: - ListBenefit
struct ListBenefit: Codable {
    let maximumAmount: Int
}

// MARK: - ListProductSideBenefit
struct ContractListProductSideBenefit: Codable {
    let id, name: String
    let content: String?
    let scope: String
    let sideBenefitId: String?
    let applicableGender, fromAge, toAge: Int
    let listFeeAndMaximumAmountSideBenefit: [ListBenefit]?
    let listProductSubSideBenefit: [ContractSubBenefit]?
}

// MARK: - ContractSubBenefit
struct ContractSubBenefit: Codable {
    let name: String
    let content: String?
}

// MARK: - InsuranceTermsModel
struct InsuranceTermsModel: Codable {
    let id, companyID, programID: String
    let listExclusionTerms, listParticipationTerms: [ListSubTerm]
    let highlight, benefit, applicableObject, feePaymentMethod: String?
    let hospital: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyID = "companyId"
        case programID = "programId"
        case listExclusionTerms, listParticipationTerms, highlight, benefit, applicableObject, feePaymentMethod, hospital
    }
}

// MARK: - ListSubTerm
struct ListSubTerm: Codable {
    let id, termsID, name: String
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case termsID = "termsId"
        case name, content
    }
}

// MARK: - SmartpayOrderModel
struct SmartpayOrderModel: Codable {
    let created, traceID, channel, merchantID: String
    let orderNo, branchCode, status: String
    
    enum CodingKeys: String, CodingKey {
        case created
        case traceID = "traceId"
        case channel
        case merchantID = "merchantId"
        case orderNo, branchCode, status
    }
}

enum SmartpayOrderEnum: String {
    case OPEN
    case PAYED
    case PAY_ERROR
}
