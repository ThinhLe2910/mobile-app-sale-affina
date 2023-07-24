//
//  ClaimService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 01/03/2023.
//

import Foundation

class ClaimService {
    
    
    func createClaimRequest(model: ClaimRequestModel, completion: @escaping ((Result<APIResponse<NilData>, ApiError>) -> Void)) {
        Logger.Logs(message: model.dict)
        let body: Data? = try? JSONSerialization.data(withJSONObject: model.dict, options: [])
        let request = BaseApiRequest(path: API.Claim.CREATE_CLAIM, method: .post, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NilData>, ApiError>) in
            completion(result)
        }
    }
    
    func getListBanks(completion: @escaping ((Result<APIResponse<[Bank]>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Claim.GET_BANKS, method: .get, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[Bank]>, ApiError>) in
            completion(result)
        }
    }
    
    func getClaimDetail(id: String, completion: @escaping ((Result<APIResponse<ClaimDetailModel>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Claim.CREATE_CLAIM, method: .get, parameters: ["id":id], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<ClaimDetailModel>, ApiError>) in
            completion(result)
        }
    }
    
    func getInsuredPersons(completion: @escaping ((Result<APIResponse<[InsuredNameModel]>, ApiError>) -> Void)) {
        let fields: [String: Any] = ["limit": 100]
        let body: Data? = try? JSONSerialization.data(withJSONObject: fields, options: [])
        let request = BaseApiRequest(path: API.Card.GET_INSURED_NAME, method: .post, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[InsuredNameModel]>, ApiError>) in
           completion(result)
        }
    }
}
