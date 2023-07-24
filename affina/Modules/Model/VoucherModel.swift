//
//  VoucherModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/03/2023.
//

import Foundation

// MARK: VoucherSummaryModel
struct VoucherSummaryModel: Codable {
    let coin: Double?
    let voucherExp: Int?
}

// MARK: - VoucherCategoryModel
struct VoucherCategoryModel: Codable {
    let categoryID: String?
    let categoryName: String?
    let createdAt: Int?
    let categoryIcon: String?
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "categoryId"
        case categoryName, createdAt, categoryIcon
    }
}

// MARK: - ListVoucherModel
struct ListVoucherModel: Codable {
    let list: [VoucherModel]
    let total: Int
}
// MARK: - ListVoucherModel
struct ListModel<T: Codable>: Codable {
    let list: [T]
    let total: Int
}


struct VoucherDetailModel: Codable {
    let voucherId: String?
    let voucherName: String?
    let summary: String?
    let expireDate: Double?
    let content: String?
    let price: Int?
    let images: String?
    let image: String?
    let expireInfo: String?
    let totalRatingPoint: Int?
    let totalRating: Int?
    let ratingList: [VoucherRatingModel]?
    var providerId: String?
    let status: Int?
}

struct VoucherRatingModel: Codable {
    var createdAt: Double
    var ratingPoint: Int?
    var avatar: String?
    var userId: String?
    var images: String?
    var comment: String?
    var name: String?
}

// MARK: - DataClass
struct ListMyVoucherModel: Codable {
    let list: [MyVoucherModel]
    let total: Int
}

// MARK: - MyVoucherModel
struct MyVoucherModel: Codable {
    let voucherID: String?
    let campaignID: String?
    let userID: String?
    let code: String?
    let serial: String?
    let imageCode: String?
    let isUse: Int?
    let expiredAt: Double?
    let providerID: String?
    let voucherName: String?
    let voucherImage: String?
    let summary: String?
    let content: String?
    let totalRating: Int?
    let totalRatingPoint: Int?
    let ratingList: [VoucherRatingModel]?
    
    enum CodingKeys: String, CodingKey {
        case voucherID = "voucherId"
        case campaignID = "campaignId"
        case userID = "userId"
        case code, expiredAt, isUse, serial
        case providerID = "providerId"
        case voucherName, voucherImage
        case ratingList
        case summary
        case content
        case totalRatingPoint
        case totalRating
        case imageCode = "codeImage"
    }
}


// MARK: - VoucherModel
struct VoucherModel: Codable {
    let voucherId, voucherName, providerId: String?
    let price: Int?
    let image: String?
    let images: String?
    let totalRatingPoint: Int?
    let totalRating: Int?
    
    let discountApplyType: Int?
    
    enum CodingKeys: String, CodingKey {
        case voucherId = "voucherId"
        case voucherName
        case providerId = "providerId"
        case price, image
        case images
        case totalRating
        case totalRatingPoint
        case discountApplyType
    }
}

struct VoucherHistoryModel: Codable {
    let voucherId, voucherName, transactionId: String?
    let coin, totalCoin: Int?
    let point, totalPoint: Int?
    let createdAt: Double?
}

struct BuyVoucherResponse: Codable {
    let coin: Double?
    let point: Double?
}

struct ContractVoucherModel: Codable {
    let amountPay: Double?
    let amountDiscount: Double?
    let paymentMethodVoucher: Int?
}
