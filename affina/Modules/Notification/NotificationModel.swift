//
//  NotificationModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 05/01/2023.
//

import Foundation

struct NotificationModel: Codable {
    let id: String?
    let notificationId: String?
    let userID: String?
    let status: Double?
    let createdAt: Double
    let createdBy: String?
    let modifiedAt: Double?
    let modifiedBy: String?
    let icon: String?
    let contentShort: String?
    let eventId: String?
}

struct NotificationTopicModel: Codable {
    var id: String? = nil
    var name: String? = nil
    var display: Double? = nil
    var createdAt: Double? = nil
    var createdBy: String? = nil
    var modifiedAt: Double? = nil
    var modifiedBy: String? = nil
}

struct GetNotificationModel: Codable {
    var createdAt: Double? = nil
    var id: String? = nil
    var limit: Int? = nil
    var notificationTopicId: String? = nil
}

struct NotificationDetailModel: Codable {
    var id: String? = nil
    var notificationTopicId: String? = nil
    var notificationTopicName: String? = nil
    var type: Double? = nil
    var sendTime: Double? = nil
    var endTime: Double? = nil
    var times: Double? = nil
    var periodType: Double? = nil
    var periodvarue: Double? = nil
    var contentType: Int? = nil
    var contentDynamicId: String? = nil
    var contentDynamicType: Int? = nil
    var title: String? = nil
    var name: String? = nil
    var contentShort: String? = nil
    var contentLong: String? = nil
    var icon: String? = nil
    var image: String? = nil
    var isCare: Int? = nil
    var link: String? = nil
    var createdAt: Double? = nil
    var createdBy: String? = nil
    var modifiedAt: Double? = nil
    var modifiedBy: String? = nil
}
