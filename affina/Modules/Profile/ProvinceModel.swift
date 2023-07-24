//
//  ProvinceModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 27/07/2022.
//

import Foundation

struct CityModel: Codable {
    let cityName: String
    let cityCode: Int
}

struct DistrictModel: Codable {
    let districtsName: String
    let districtsCode: Int
}

struct WardModel: Codable {
    let wardsName: String
    let wardsCode: Int
}
