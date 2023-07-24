//
//  APIResponse.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 26/05/2022.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let code: String
    let messages: String?
    let data: T?
}

// To pass "data: {}" in CheckPhone api or other features
struct NilData: Codable {
    let key: String?
    let value: String?
}

struct ConfigData: Codable {
    let keyName: String
    let value: String
}

struct LinkData: Codable {
    let link: String?
}

struct LinkImagesData: Codable {
    let files: [File]
}

struct File: Codable {
    let name, link: String
    let ext: String
}

struct Bank: Codable {
    let bankCode, bankName: String
    let bankId: String
}

struct CoSoYTeModel: Codable {
    let id, code, name: String
    let parentID: Int

    enum CodingKeys: String, CodingKey {
        case id, code, name
        case parentID = "parentId"
    }
}
struct APIResponseBaoMinh<T: Decodable>: Decodable {
    let code: Int
    let status: String
    let messages: String?
    let data: T?
}
struct PagedListDataRespone : Codable{
    let currentItemCount : Int
    let itemsPerPage : Int
    let totalItems : Int
    let pageIndex : Int
    let totalPages : Int
    let items : [BaoMinhProvider]
}
struct BaoMinhProvider: Codable {
    let id : Int
    let name: String
    let code :String?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case code
    }
}
