//
//  EventModel.swift
//  affina
//
//  Created by Intelin MacHD on 04/04/2023.
//

import Foundation

struct EventBannerModel: Codable {
    let campaignId: String?
    let action: Int?
    let actionContent: String?
    let images: String?
    let shortDesc: String?
    let description: String?
    let createdAt: Int64?
}

struct EventModel: Codable {
    let campaignId: String?
    let images: String?
    let shortDesc: String?
    let description: String?
    let createdAt: Int64?
    let listVoucher: [EventVoucherModel]?
}

struct EventVoucherModel: Codable{
    let voucherId: String?
    let voucherName: String?
    let price: Int?
    let images: String?
    let toDate: Int64?
}
