//
//  FlexiModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 17/03/2023.
//

import Foundation

struct FlexiSummaryModel: Codable {
    var point: Int?
    let expiredAt: Double?
    let benefitCount: Int?
//    let dayOffs: Int?
    let usedPoint: Int?
}

struct FlexiBenefitModel: Codable {
    let benefitId: String?
    let benefitName: String?
    let type: FlexiTypeEnum?
    let status: FlexiStatusEnum?
    let startDate: Double?
    let amount: Int?
    let point: Int?
    let maxDay: Int?
    let dob: Double?
    let isUse: Int?
}

enum FlexiTypeEnum: Int, Codable {
    case OTHER = 0
    case BIRTHDAY = 1
    case EXCHANGE_DAY_OFF = 2
}

enum FlexiStatusEnum: Int, Codable {
    case UPCOMING = 0
    case HAPPENING = 1
    case FINISHED = 2
}

struct FlexiExchangeDaysModel: Codable {
    let exchangeDays: Int?
    let points: Int?
}

