//
//  InsuranceService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 22/03/2023.
//

import Foundation

class InsuranceService {
    
    func getProductDetail(id: String, gender: Int, dob: Double, completion: @escaping ((Result<APIResponse<ProductDetailModel>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Sale.GET_PRODUCT_DETAIL, method: .get, parameters: ["id": id, "gender":"\(gender)", "dob":"\(Int(dob))"], isJsonRequest: false, headers: [:], httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<ProductDetailModel>, ApiError>) in
            completion(result)
        }
    }
    
    
    func getTerms(programId: String, completion: @escaping ((Result<APIResponse<InsuranceTermsModel>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Sale.GET_TERMS, method: .get, parameters: ["programId":programId], isJsonRequest: false, headers: [:], httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<InsuranceTermsModel>, ApiError>) in
            completion(result)
        }
    }
}
