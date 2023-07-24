//
//  APIRequest.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/05/2022.
//

import Alamofire

protocol APIRequest {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [String : Any] { get }
    var headers: [String: String] { get }
    var httpBody: Data? { get }
    var encoding: ParameterEncoding { get }
    
}

extension APIRequest {
    func request() -> URLRequest {
        guard let url = URL(string: self.path), var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URLComponents")
        }
        
        components.queryItems = parameters.map {
            URLQueryItem(name: $0.key, value: $0.value as? String)
        }
        
        guard let url = components.url else {
            fatalError("Could not get url")
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = httpBody
//        var headers = HTTPHeaders()
//        self.headers.forEach { key, value in
//            headers.add(name: key, value: value)
//        }
//        var parameters = Parameters()
//        self.parameters.forEach { key, value in
//            parameters.updateValue(value, forKey: key)
//        }
        
        return request
    }
    
}

class BaseApiRequest: APIRequest {
    var encoding: ParameterEncoding = JSONEncoding.default
    var method: HTTPMethod
    var path: String
    var parameters: [String: Any]
    var headers: [String: String]
    var httpBody: Data?

    init(path: String = "", method: HTTPMethod = .get, parameters: [String: Any] = [:], isJsonRequest: Bool = true, headers: [String: String] = [:], httpBody: Data? = nil) {
        self.path = path
        self.parameters = parameters
        self.headers = headers
        self.httpBody = httpBody
        self.method = method
        if !isJsonRequest {
            self.encoding = URLEncoding.default
        }
    }
}
