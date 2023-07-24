//
//  ContractService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 01/03/2023.
//

import Foundation

class ContractService {
    
    func getListContracts(completion: @escaping ((Result<APIResponse<[ContractModel]>, ApiError>) -> Void)) {
        // TODO: Update load more function
        let fields: [String: Any] = ["order": "contractId",
                                     "by": "asc",
                                     "from": 0,
                                     "limit": 1000
        ]
        
        var body: Data?
        do {
            body = try JSONSerialization.data(withJSONObject: fields, options: .prettyPrinted)
        } catch { }
        
        let request = BaseApiRequest(path: API.Contract.GET_CONTRACT_LIST, method: .delete, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[ContractModel]>, ApiError>) in
            completion(result)
        }
        
    }
    func getContractDetail(contractId: String, completion: @escaping ((Result<APIResponse<ContractDetailModel>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Contract.GET_CONTRACT_DETAIL, method: .get, parameters: ["contractId": contractId], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<ContractDetailModel>, ApiError>) in
            completion(result)
        }
    }
}
