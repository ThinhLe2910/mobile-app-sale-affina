//
//  CardService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 01/03/2023.
//

import Foundation

class CardService {
    
    func getListCards(limit: Int = 10, completion: @escaping ((Result<APIResponse<[CardModel]>, ApiError>) -> Void)) {
        let body: [String: Any] = [
            "limit": limit
        ]
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        let request = BaseApiRequest(path: API.Card.GET_CARD_LIST, method: .delete, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: data)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[CardModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getMoreListCards(contractId: String, contractObjectId: String, createdAt: Double, completion: @escaping ((Result<APIResponse<[CardModel]>, ApiError>) -> Void)) {
        let body: [String: Any] = [
            "contractId": contractId,
            "contractObjectId": contractObjectId,
            "createdAt": createdAt,
            "limit": 10
        ]
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let request = BaseApiRequest(path: API.Card.GET_CARD_LIST, method: .delete, parameters: body, isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: data)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[CardModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getListCardsByName(name: String, completion: @escaping ((Result<APIResponse<[CardModel]>, ApiError>) -> Void)) {
        let body: [String: Any] = [
            "name": name,
            "limit": 10
        ]
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let request = BaseApiRequest(path: API.Card.GET_CARD_LIST, method: .post, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: data)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[CardModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getMoreListCardsByName(name: String, contractId: String, contractObjectId: String, createdAt: Double, completion: @escaping ((Result<APIResponse<[CardModel]>, ApiError>) -> Void)) {
        let body: [String: Any] = [
            "contractId": contractId,
            "createdAt": createdAt,
            "contractObjectId": contractObjectId,
            "name": name,
            "limit": 10
        ]
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])

        let request = BaseApiRequest(path: API.Card.GET_CARD_LIST, method: .post, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: data)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[CardModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getClaimList(contractObjectId: String, claimId: String = "", createdAt: Int = 0, status: Int? = nil, dateFrom: Int? = nil, dateTo: Int? = nil, completion: @escaping ((Result<APIResponse<[ClaimHistoryModel]>, ApiError>) -> Void)) {
        var body: [String: Any] = [
            "limit": 10,
            "contractObjectId": contractObjectId.isEmpty ? "" : contractObjectId
        ]
        
        if !claimId.isEmpty {
            body["claimId"] = claimId
        }
        
        if createdAt != 0 {
            body["createdAt"] = createdAt
        }
        
        if status != nil {
            body["status"] = status!
        }
        
        if dateFrom != nil {
            body["dateFrom"] = dateFrom!
        }
        
        if dateTo != nil {
            body["dateTo"] = dateTo!
        }
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        let request = BaseApiRequest(path: API.Claim.CREATE_CLAIM, method: .delete, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: data)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[ClaimHistoryModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getHospitalList(contractObjectId: String, hospitalId: String = "", createdAt: Int = 0, isBlackList: Bool = false, search: String = "", completion: @escaping ((Result<APIResponse<[HospitalModel]>, ApiError>) -> Void)) {
        var body: [String: Any] = createdAt == 0 ? [
            "id": hospitalId,
            "limit": 10,
            "type": isBlackList ? HospitalProviderType.BLACKLIST.rawValue : HospitalProviderType.GUARANTEE.rawValue,
            "contractObjectId": contractObjectId.isEmpty ? "" : contractObjectId
        ] : [
            "id": hospitalId,
            "createdAt": createdAt,
            "limit": 10,
            "type": isBlackList ? HospitalProviderType.BLACKLIST.rawValue : HospitalProviderType.GUARANTEE.rawValue,
            "contractObjectId": contractObjectId.isEmpty ? "" : contractObjectId
        ]
        
        if !search.isEmpty {
            body["search"] = search
        }
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let request = BaseApiRequest(path: API.Card.GET_HOSPITAL_LIST, method: .delete, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: data)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[HospitalModel]>, ApiError>) in
            completion(result)
        }
    }
}
