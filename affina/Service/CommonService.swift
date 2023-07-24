//
//  CommonService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/03/2023.
//

import Foundation
import Alamofire

class CommonService {
    
    func getListCity(completion: @escaping (Result<[CityModel], Error>) -> Void) {
        let request = BaseApiRequest(path: API.Other.GET_LIST_CITY, method: .get, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[CityModel]>, ApiError>) in
            switch result {
                case .success(let response):
                    completion(.success(response.data ?? []))
                case .failure(let error):
                    Logger.Logs(message: error)
                    completion(.failure(error))
                    break
            }
        }
    }
    
    func getListDistrict(cityCode: String, completion: @escaping (Result<[DistrictModel], Error>) -> Void) {
        let request = BaseApiRequest(path: API.Other.GET_LIST_DISTRICT, method: .get, parameters: ["cityCode": cityCode], isJsonRequest: false, headers: [:], httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[DistrictModel]>, ApiError>) in
            switch result {
                case .success(let response):
                    completion(.success(response.data ?? []))
                case .failure(let error):
                    Logger.Logs(message: error)
                    completion(.failure(error))
                    break
            }
        }
    }
    
    func getListWard(districtCode: String, completion: @escaping (Result<[WardModel], Error>) -> Void) {
        let request = BaseApiRequest(path: API.Other.GET_LIST_WARD, method: .get, parameters: ["districtsCode": districtCode], isJsonRequest: false, headers: [:], httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[WardModel]>, ApiError>) in
            switch result {
                case .success(let response):
                    completion(.success(response.data ?? []))
                case .failure(let error):
                    Logger.Logs(message: error)
                    completion(.failure(error))
                    break
            }
        }
    }
    
    // MARK: Get list CSYT by keyword
    func getListCSYT(keyword: String = "", pageIndex: Int = 1, pageSize: Int = 10, completion: @escaping (Result<[CoSoYTeModel], ApiError>) -> Void) {
        var fields: [String: Any] = [
            "dicGroupCode": "CoSoYTe",
            "pageSize": "\(pageSize)",
            "pageIndex": "\(pageIndex)"
        ]
        if !keyword.isEmpty {
            fields["keyWord"] = keyword
        }
        let body: Data? = try? JSONSerialization.data(withJSONObject: fields, options: [])
        let request = BaseApiRequest(path: API.Claim.GET_DICTIONARY, method: .get, parameters: fields, isJsonRequest: false, headers: [:], httpBody: nil)
        //        let request = BaseApiRequest(path: API.Claim.GET_DICTIONARY + "CoSoYTe\(keyword.isEmpty ? "" : "&keyWord=\(keyword)")&pageIndex=\(pageIndex)&pageSize=\(pageSize)", method: .get, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[CoSoYTeModel]>, ApiError>) in
            switch result {
                case .success(let response):
                print(response.data)
                    completion(.success(response.data ?? []))
                case .failure(let error):
                    Logger.Logs(message: error)
                    completion(.failure(error))
                    break
            }
        }
    }
    
    func getListCSYTBaoMinh(keyword: String = "", pageIndex: Int = 1, pageSize: Int = 10, completion: @escaping (Result<PagedListDataRespone, ApiError>) -> Void) {
        var  request :BaseApiRequest?
        if !keyword.isEmpty {
            var fields : [String : Any] = ["search": keyword]
            let body: Data? = try? JSONSerialization.data(withJSONObject: fields, options: [])
            request = BaseApiRequest(path: API.Claim.GET_BAO_MINH_PROVIDERS, method: .get, parameters: fields, isJsonRequest: false, headers: [:], httpBody: nil)
        }else{
            request = BaseApiRequest(path: API.Claim.GET_BAO_MINH_PROVIDERS, method: .get, isJsonRequest: false, headers: [:], httpBody: nil)
        }
       
        APIManager.shared.sendBaoMinh(request: request!) { (result: Result<APIResponseBaoMinh<PagedListDataRespone>, ApiError>) in
            switch result {
                case .success(let response):
                completion(.success(response.data!))
                case .failure(let error):
                print("error")
                    Logger.Logs(message: error)
                    completion(.failure(error))
                    break
            }
        }
    }
    
    func getConfig(completion: @escaping ((Result<APIResponse<[ConfigData]>, Error>) -> Void)) {
        let request = BaseApiRequest(path: API.User.USER_CONFIG, method: .get, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil)
        AF.request(request.request()).response { response in
            switch response.result {
                case .success(let data):
                    guard let result = try? JSONDecoder().decode(APIResponse<[ConfigData]>.self, from: data!) else {
                        completion(.failure(NSError()))
                        return
                    }
                    completion(.success(result))
                    break
                case .failure(let error):
                    Logger.Logs(message: error)
                    completion(.failure(error))
                    break
            }
        }
    }
    
    func getAllSetup(completion: @escaping ((Result<APIResponse<SetupModel>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Other.GET_ALL_SETUP, method: .get, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<SetupModel>, ApiError>) in
            completion(result)
            
            switch result {
                case .success(let data):
                    guard let list = data.data else { return }
                    LayoutBuilder.shared.setSetupModel(list)
                case .failure(_):
                    break
            }
        }
        
    }

}
