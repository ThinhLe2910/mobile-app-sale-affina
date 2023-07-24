//
//  ProfileService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 01/03/2023.
//

import UIKit

class ProfileService {
    
    func updateProfile(dict: [String: Any], completion: @escaping ((Result<APIResponse<NilData>, ApiError>) -> Void)) {
        let data: Data? = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let request = BaseApiRequest(path: API.User.UPDATE_PROFILE, method: .post, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: data)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NilData>, ApiError>) in
            completion(result)
        }
    }
    
}
