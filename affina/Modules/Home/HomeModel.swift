//
//  HomeModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 17/08/2022.
//

import UIKit

enum LabelEnum: Int {
    case NO_TAG = 0
    case OUTSTANDING = 1
}

struct HomeFeaturedProduct: Codable {
    let id: String?
    let name: String?
    let image: String?
    let fee: Int?
    let rate: CGFloat?
    var label: Int?
}

struct HomeCategoryModel {
    let id: Int?
    let name: String?
    let imageURL: String?
}

struct NotificationStatusModel: Codable {
    let status: Int?
}

struct HomeBannerModel: Codable {
    let campaignId: String?
    let action: Int?
    let actionContent: String?
    let images: String?
    let shortDesc: String?
    let description: String?
}

struct HomeEventModel: Codable {
    let campaignBannerId: String?
    let popupImg: String?
    let campaignId: String?
}
