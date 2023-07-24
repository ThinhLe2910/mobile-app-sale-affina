//
//  APIManger.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import UIKit
import Alamofire
import SwiftyJSON

// TODO: Check internet availabel : Alamofire.NetworkReachabilityManager

public class API {
    private enum Config: String {
        case DEV_ENV     = "https://api.affina.dev.intelin.vn/"
        case STAGING_ENV = "https://api.affina.stg.intelin.vn/"
        case UAT_ENV     = "https://api-uat.affina.com.vn/"
        case LIVE_ENV    = "https://api.affina.com.vn/"
        
        case USER_ENV = "user/"
        case SALE_ENV = "sale/"
        case OTHER_ENV = "other/"
        
    }
    
    // MARK: Change this variable to change the type of api
    static var networkEnvironment: NetworkEnvironment = .uat

    public static func setEnvironment(environment: Int) {
        UIConstants.environment = environment
    }
    
    private static func getEnvironment() -> String {
        switch networkEnvironment {
        case .dev:
            return Config.DEV_ENV.rawValue + Config.USER_ENV.rawValue
        case .staging:
            return Config.STAGING_ENV.rawValue + Config.USER_ENV.rawValue
        case .uat:
            return Config.UAT_ENV.rawValue + Config.USER_ENV.rawValue
        case .live:
            return Config.LIVE_ENV.rawValue + Config.USER_ENV.rawValue
        }
    }
    private static func getEnvironmentForBaoMinh()-> String{
        switch networkEnvironment {
        case .dev:
            return Config.DEV_ENV.rawValue
        case .staging:
            return Config.STAGING_ENV.rawValue
        case .uat:
            return Config.UAT_ENV.rawValue
        case .live:
            return Config.LIVE_ENV.rawValue
        }
    }
    private static func getSaleEnvironment() -> String {
        switch networkEnvironment {
        case .dev:
            return Config.DEV_ENV.rawValue + Config.SALE_ENV.rawValue
        case .staging:
            return Config.STAGING_ENV.rawValue + Config.SALE_ENV.rawValue
        case .uat:
            return Config.UAT_ENV.rawValue + Config.SALE_ENV.rawValue
        case .live:
            return Config.LIVE_ENV.rawValue + Config.SALE_ENV.rawValue
        }
    }
    
    private static func getOtherEnvironment() -> String {
        switch networkEnvironment {
        case .dev:
            return Config.DEV_ENV.rawValue + Config.OTHER_ENV.rawValue
        case .staging:
            return Config.STAGING_ENV.rawValue + Config.OTHER_ENV.rawValue
        case .uat:
            return Config.UAT_ENV.rawValue + Config.OTHER_ENV.rawValue
        case .live:
            return Config.LIVE_ENV.rawValue + Config.OTHER_ENV.rawValue
        }
    }
    
    static var STATIC_RESOURCE = ""
    
    public struct Other {
        static let PUBLIC_UPLOAD = API.getOtherEnvironment() + "public/upload"
        
        static let GET_LIST_CITY = API.getOtherEnvironment() + "public/city"
        static let GET_LIST_DISTRICT = API.getOtherEnvironment() + "public/district"
        static let GET_LIST_WARD = API.getOtherEnvironment() + "public/ward"
        
        static let GET_ALL_SETUP = API.getOtherEnvironment() + "public/setupTemplateImage?appUser=1"
    }
    
    public struct User {
        // KYC
        static var LOGIN: String {
            return API.getEnvironment() + "user/login"
        }
        static var CHECK_PHONE_NUMBER: String {
            return API.getEnvironment() + "user/login"
        }
        static var GET_OTP_REGISTER: String {
            return API.getEnvironment() + "user/register"
        }
        static var REGISTER_ACCOUNT: String {
            return API.getEnvironment() + "user/register" // POST
        }
        
        static var SUBMIT_OTP: String {
            return API.getEnvironment() + "otp" // PUT, DELETE
        }
        
        static var GET_OTP_FORGOT_PASSWORD: String {
            return API.getEnvironment() + "user/password"
        }
        
        static var FORGOT_PASSWORD: String {
            return API.getEnvironment() + "user/password"
        }
        
        static var REFRESH_TOKEN: String {
            return API.getEnvironment() + "token"
        }
        
        // Profile
        static var GET_PROFILE: String {
            return API.getEnvironment() + "user/account/profile"
        }
        static var UPDATE_PROFILE: String {
            return API.getEnvironment() + "user/account/profile"
        }
        
        static var LOG_OUT: String {
            return API.getEnvironment() + "user/logout"
        }
        static var USER_CONFIG: String {
            return API.getEnvironment() + "config"
        }
        
        // PUBLIC
        static var GET_LIST_COMPANY_PROVIDER: String {
            return API.getSaleEnvironment() + "public/company/provider"
        }
    }
    
    public struct Campaign {
        static var GET_BANNER: String {
            return API.getSaleEnvironment() + "/user/campaign/banner"
        }
        
        static var GET_POPUP: String {
            return API.getSaleEnvironment() + "/user/campaign/popup"
        }
        
        static var GET_DETAIL_BANNER: String {
            return API.getSaleEnvironment() + "/user/campaign/aff"
        }
        
        static var GET_DETAIL_POPUP: String {
            return API.getSaleEnvironment() + "/user/campaign/voucher"
        }
    }
    
    public struct Contract {
        static var CREATE_CONTRACT: String {
            return API.getSaleEnvironment() + "public/contract" // POST: create contract, PUT: update contract
        }
        static var CREATE_CONTRACT_WITH_TOKEN: String {
            return API.getSaleEnvironment() + "user/contract" // POST: create contract, PUT: update contract
        }
        
        static var GET_CONTRACT_LIST: String {
            return API.getSaleEnvironment() + "user/contract"
        }
        
        static var GET_CONTRACT_DETAIL: String {
            return API.getSaleEnvironment() + "user/contract"
        }
        
        static var REGISTER_AFTER_CREATE_CONTRACT: String {
            return API.getEnvironment() + "user/register/contract"
        }
        
        static var GET_STATUS_ORDER_SMARTPAY: String {
            return API.getSaleEnvironment() + "public/transaction"
        }
    }
    
    public struct Card {
        static var GET_CARD_LIST: String {
            return API.getSaleEnvironment() + "/user/card" // DEL
        }
        
        static var GET_HOSPITAL_LIST: String {
            return API.getSaleEnvironment() + "/user/hospital" // DEL
        }
        
        static var GET_INSURED_NAME: String {
            return API.getSaleEnvironment() + "/user/card/name"
        }
        
    }
    
    public struct Claim {
        static var CREATE_CLAIM: String {
            return API.getSaleEnvironment() + "user/claim"
        }
        static var GET_BANKS: String {
            return API.getSaleEnvironment() + "/bank/tpa"
        }
        static var GET_DICTIONARY: String {
            return API.getSaleEnvironment() + "dictionary/smart/tpa"
        }
        static var GET_BAO_MINH_PROVIDERS: String {
            return API.getEnvironmentForBaoMinh() + "public/bao-minh-providers"
        }
    }
    
    public struct Home {
        static var GET_HOME: String {
            return API.getEnvironment() + ""
        }
        
        static var GET_BANNERS: String {
            return API.getSaleEnvironment() + "public/banner"
        }
        
        static var GET_FEATURED_PRODUCTS: String {
            return API.getSaleEnvironment() + "public/product/outstanding"
        }
        
        static var GET_LOGGED_IN_FEATURED_PRODUCTS: String {
            return API.getSaleEnvironment() + "user/product/outstanding"
        }
        
    }
    
    public struct News {
        static var GET_CATEGORY: String {
            return API.getOtherEnvironment() + "public/news/topic"
        }
        static var GET_OUTSTANDING_NEWS: String {
            return API.getOtherEnvironment() + "public/news"
        }
        
        static var LIKE_NEWS: String {
            return API.getOtherEnvironment() + "news/like" // POST: like, PUT: unlike
        }
        
        static var COMMENT_NEWS: String {
            return API.getOtherEnvironment() + "news/comment"
        }
    }
    
    public struct Sale {
        // PUBLIC
        static var GET_ALL_PROGRAM_TYPE: String {
            return API.getSaleEnvironment() + "public/programType"
        }
        static var POST_FILTER_PRODUCT: String {
            return API.getSaleEnvironment() + "public/product"
        }
        static var GET_PRODUCT_DETAIL: String {
            return API.getSaleEnvironment() + "public/product"
        }
        static var PUT_CHECK_PRODUCT: String {
            return API.getSaleEnvironment() + "public/product" // Kiem tra thong tin
        }
        
        // TERMS
        static var GET_TERMS: String {
            return API.getSaleEnvironment() + "public/terms"
        }
        
        
    }
    
    // MARK: Notification
    public struct Notification {
        static var GET_LIST_TOPICS: String {
            return API.getOtherEnvironment() + "user/notification/topic"
        }
        static var GET_LIST_NOTIFICATION: String {
            return API.getOtherEnvironment() + "user/notification"
        }
        static var GET_NOTIFICATION_DETAIL: String {
            return API.getOtherEnvironment() + "user/notification"
        }
        static var GET_LIST_EVENTS: String {
            return API.getOtherEnvironment() + "user/event"
        }
        static var GET_EVENT_DETAIL: String {
            return API.getOtherEnvironment() + "user/event"
        }
        static var CARE_EVENT: String {
            return API.getOtherEnvironment() + "user/event"
        }
    }
    
    // MARK: Voucher
    public struct Voucher {
        static var GET_LIST_CATEGORY: String {
            return API.getSaleEnvironment() + "public/voucher/category"
        }
        
        static var GET_LIST_VOUCHER_BY_CATEGORY: String {
            return API.getSaleEnvironment() + "public/voucher?categoryId="
        }
        
        static var GET_VOUCHER_DETAIL: String {
            return API.getSaleEnvironment() + "public/voucher/detail?voucherId="
        }
        
        static var GET_VOUCHER_AT: String {
            return API.getSaleEnvironment() + "public/voucher"
        }
        
        static var BUY_VOUCHER: String {
            return API.getSaleEnvironment() + "user/voucher"
        }
        
        static var GET_MY_VOUCHER_DETAIL: String {
            return API.getSaleEnvironment() + "user/voucher/detail?voucherId="
        }
        
        static var GET_MY_LIST_VOUCHER: String {
            return API.getSaleEnvironment() + "user/voucher/stock"
        }
        
        static var RATING_VOUCHER: String {
            return API.getSaleEnvironment() + "user/voucher/rating"
        }
        
        static var MARK_USED_VOUCHER: String {
            return API.getSaleEnvironment() + "user/voucher/used"
        }
        
        static var CHECK_CONTRACT_VOUCHER: String {
            return API.getSaleEnvironment() + "public/contract/voucher"
        }
        
        static var CHECK_CONTRACT_VOUCHER_USER: String {
            return API.getSaleEnvironment() + "user/contract/voucher"
        }
        
        // MARK: SME
        static var GET_LIST_SME_VOUCHER_BY_CATEGORY: String {
            return API.getSaleEnvironment() + "sme/voucher?categoryId="
        }
        
        static var GET_MY_SME_VOUCHER_DETAIL: String {
            return API.getSaleEnvironment() + "sme/voucher/detail?voucherId="
        }
        
        static var BUY_SME_VOUCHER: String {
            return API.getSaleEnvironment() + "sme/voucher"
        }
        
    }
    
    // MARK: Flexi
    struct Flexi {
        static var GET_SUMMARY_FLEXI_POINT: String {
            return API.getEnvironment() + "sme/flexi/point"
        }
        
        static var GET_LIST_FLEXI: String {
            return API.getEnvironment() + "sme/flexi/benefit"
        }
        
        static var EXCHANGE_DAY_OFF_BENEFIT: String {
            return API.getEnvironment() + "sme/flexi/point"
        }
        
        static var GET_LIST_CARD_SME: String {
            return API.getSaleEnvironment() + "user/card"
        }
    }
    
    public struct Payoo {
        //        - Sandbox environment: https://newsandbox.payoo.com.vn/v2
        //        - Live environment: https://payoo.vn/v2
        static let BANK_LOGO = "https://payoo.vn/v2/img/banks-logo-new/@.png" // https://payoo.vn/v2/img/banks-logo-new/citibank.png
        static let GET_BANK_CODE = "https://newsandbox.payoo.com.vn/v2/api/paynow/get-banks-partner?code=Ecommerce&url={0}&id={1}&seller={2}&jsonCallback=0" // https://newsandbox.payoo.com.vn/v2/api/paynow/get-banks-partner?code=Ecommerce&url=http://localhost&id=858&seller=iss_Ipay88_master&jsonCallback=0
        
    }
}

class APIManager {
    private init() { }
    static let shared = APIManager()
    
    var token: String = String()
    
    public func getSimpleHeader() -> [String: String] {
        let headers = [
            "Content-Type": "application/json",
            "Accept": "*/*"
        ]
        return headers
    }
    
    public func getTokenHeader() -> [String: String] {
        let headers = [
            "Content-Type": "application/json",
            "Accept": "*/*",
            "token": UserDefaults.standard.string(forKey: Key.token.rawValue) ?? ""
        ]
        return headers
    }
    
    public func getSimpleHeader() -> HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "Accept", value: "*/*")
        return headers
    }
    
    public func getTokenHeader() -> HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "Accept", value: "*/*")
        headers.add(name: "token", value: UserDefaults.standard.string(forKey: Key.token.rawValue) ?? "")
        return headers
    }
    
    
    func sendBaoMinh<T>(request: APIRequest, completion: @escaping (Result<APIResponseBaoMinh<T>, ApiError>) -> Void) {
        Logger.Logs(message: request.request().curlString)
        AF.request(request.request()).responseData { [weak self] response in
            switch response.result {
            case .success(let res):
                if let code = response.response?.statusCode {
                    switch code {
                    case 200...299:
                        do {
                            let json = try? JSON(data: res, options: .fragmentsAllowed) // For debug logging
                            Logger.Logs(event: .info, message: request.path)
                            Logger.Logs(event: .info, message: json)
                            let model = try JSONDecoder().decode(APIResponseBaoMinh<T>.self, from: res)
                            if String(model.code) == ErrorCode.EXPIRED.rawValue {
                                completion(.failure(.expired))
                            } else {
                                completion(.success(model))
                            }
                        }
                        catch let error {
                            Logger.Logs(event: .error, message: String(data: res, encoding: .utf8) ?? "Nothing received")
                            completion(.failure(.invalidData(error, res)))
                        }
                        break
                    default:
                        let error = NSError(domain: response.debugDescription, code: code, userInfo: response.response?.allHeaderFields as? [String: Any])
                        completion(.failure(.requestTimeout(error)))
                    }
                }
            case .failure(let error):
                if error.isResponseSerializationError {
                    completion(.failure(.invalidData(error, nil)))
                    return
                }
                if error.isInvalidURLError {
                    completion(.failure(.invalidUrl))
                }
                completion(.failure(.requestTimeout(error)))
            }
        }
    }
    func send2<T>(request: APIRequest, completion: @escaping (Result<APIResponse<T>, ApiError>) -> Void) {
        //        if checkExpired() {
        //            completion(.failure(.expired))
        //            return
        //        }
        //        if checkNeedRefresh() {
        //            refreshToken { [weak self] (result: Result<UserAuthResponseData, ApiError>) in
        //                switch result {
        //                case .success(let data):
        //                    UserDefaults.standard.set(data.token, forKey: Key.token.rawValue)
        //                    UserDefaults.standard.set(data.expireAt, forKey: Key.expireAt.rawValue)
        //                    UserDefaults.standard.set(data.refreshAt, forKey: Key.refreshAt.rawValue)
        //                    UserDefaults.standard.set(data.profileDetails?.companyId, forKey: Key.companyId.rawValue)
        //                    UserDefaults.standard.set(data.profileDetails?.cusName, forKey: Key.customerName.rawValue)
        //                    UserDefaults.standard.set(true, forKey: Key.notFirstTimeLogin.rawValue)
        //                    self?.send(apiRequest: apiRequest, completion: completion)
        //                case .failure(let error):
        //                    Logger.Logs(message: error)
        //                    completion(.failure(.expired))
        //                }
        //            }
        //            return
        //        }
        Logger.Logs(message: request.request().curlString)
        AF.request(request.request()).responseData { [weak self] response in
            switch response.result {
            case .success(let res):
                if let code = response.response?.statusCode {
                    switch code {
                    case 200...299:
                        do {
                            let json = try? JSON(data: res, options: .fragmentsAllowed) // For debug logging
                            Logger.Logs(event: .info, message: request.path)
                            Logger.Logs(event: .info, message: json)
                            let model = try JSONDecoder().decode(APIResponse<T>.self, from: res)
                            if model.code == ErrorCode.EXPIRED.rawValue {
                                completion(.failure(.expired))
                            } else {
                                completion(.success(model))
                            }
                        }
                        catch let error {
                            Logger.Logs(event: .error, message: String(data: res, encoding: .utf8) ?? "Nothing received")
                            completion(.failure(.invalidData(error, res)))
                        }
                        break
                    default:
                        let error = NSError(domain: response.debugDescription, code: code, userInfo: response.response?.allHeaderFields as? [String: Any])
                        completion(.failure(.requestTimeout(error)))
                    }
                }
            case .failure(let error):
                if error.isResponseSerializationError {
                    completion(.failure(.invalidData(error, nil)))
                    return
                }
                if error.isInvalidURLError {
                    completion(.failure(.invalidUrl))
                }
                completion(.failure(.requestTimeout(error)))
            }
        }
    }
    
    func send3<T>(apiRequest: APIRequest, fileName: String = #file, funcName: String = #function, completion: @escaping (Result<APIResponse<T>, ApiError>) -> Void) where T: Codable {
        var headers = HTTPHeaders()
        apiRequest.headers.forEach { key, value in
            headers.add(name: key, value: value)
        }
        var parameters = Parameters()
        apiRequest.parameters.forEach { key, value in
            parameters.updateValue(value, forKey: key)
        }
        
        let request: URLRequestConvertible = apiRequest.request()

        AF.request(request).responseData { response in
            switch response.result {
            case .success(let res):
                if let code = response.response?.statusCode {
                    switch code {
                    case 200...299:
                        do {
                            let json = try? JSON(data: res, options: .fragmentsAllowed) // For debug logging
                            Logger.Logs(event: .info, message: json, fileName: fileName, funcName: funcName)
                            completion(.success(try JSONDecoder().decode(APIResponse<T>.self, from: res)))
                        }
                        catch let error {
                            Logger.Logs(event: .error, message: String(data: res, encoding: .utf8) ?? "Nothing received")
                            completion(.failure(ApiError.invalidData(error, res)))
                        }
                        break
                    default:
                        let error = NSError(domain: response.debugDescription, code: code, userInfo: response.response?.allHeaderFields as? [String: Any])
                        completion(.failure(ApiError.requestTimeout(error)))
                    }
                }
            case .failure(let error):
                completion(.failure(ApiError.requestTimeout(error)))
                //                completion(.failure(error))
            }
        }
    }
    
    func send<T>(apiRequest: APIRequest, fileName: String = #file, funcName: String = #function, completion: @escaping (Result<APIResponse<T>, ApiError>) -> Void) where T: Codable {
        
        
        var headers = HTTPHeaders()
        apiRequest.headers.forEach { key, value in
            headers.add(name: key, value: value)
        }
        var parameters = Parameters()
        apiRequest.parameters.forEach { key, value in
            parameters.updateValue(value, forKey: key)
        }
        
        AF.request(apiRequest.path, method: apiRequest.method, parameters: parameters, encoding: apiRequest.encoding, headers: headers)
        {
            $0.timeoutInterval = 60
        }
        .responseData { response in
            
            switch response.result {
            case .success(let res):
                if let code = response.response?.statusCode {
                    switch code {
                    case 200...299:
                        do {
                            let json = try? JSON(data: res, options: .fragmentsAllowed) // For debug logging
                            Logger.Logs(event: .info, message: json, fileName: fileName, funcName: funcName)
                            completion(.success(try JSONDecoder().decode(APIResponse<T>.self, from: res)))
                        }
                        catch let error {
                            Logger.Logs(event: .error, message: String(data: res, encoding: .utf8) ?? "Nothing received")
                            completion(.failure(ApiError.invalidData(error, res)))
                        }
                        break
                    default:
                        let error = NSError(domain: response.debugDescription, code: code, userInfo: response.response?.allHeaderFields as? [String: Any])
                        completion(.failure(ApiError.requestTimeout(error)))
                    }
                }
            case .failure(let error):
                completion(.failure(ApiError.requestTimeout(error)))
                //                completion(.failure(error))
            }
        }
    }
    
    // MARK: Refresh Model/API
    struct RefreshTokenModel: Encodable {
        let token: String
        let tokenType: Int
    }
    
    func refreshToken(completion: @escaping ((Result<UserAuthResponseData, ApiError>) -> Void)) {
        let body = RefreshTokenModel(token: UserDefaults.standard.string(forKey: Key.token.rawValue) ?? "", tokenType: 3)
        var rawJson: Data?
        do {
            let jsonData = try JSONEncoder().encode(body)
            rawJson = jsonData
        } catch { }
        
        let request = BaseApiRequest(path: API.User.REFRESH_TOKEN, method: .post, parameters: [:], isJsonRequest: true, headers: [:], httpBody: rawJson)
        self.send2(request: request) { (response: Result<APIResponse<UserAuthResponseData>, ApiError>) in
            switch response {
            case .success(let data):
                guard let model = data.data else { return }
                Logger.Logs(message: model)
                UserDefaults.standard.set(model.token, forKey: Key.token.rawValue)
                UserDefaults.standard.set(model.expireAt, forKey: Key.expireAt.rawValue)
                UserDefaults.standard.set(model.refreshAt, forKey: Key.refreshAt.rawValue)
                UserDefaults.standard.set(model.profileDetails?.companyId, forKey: Key.companyId.rawValue)
                UserDefaults.standard.set(model.profileDetails?.cusName, forKey: Key.customerName.rawValue)
                //                    UserDefaults.standard.set(true, forKey: Key.notFirstTimeLogin.rawValue)
                completion(.success(model))
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                completion(.failure(.unknown))
                break
            }
        }
    }
    
    func checkExpired() -> Bool {
        let expired = UserDefaults.standard.double(forKey: Key.expireAt.rawValue)
        let currentTime = Date().timeIntervalSince1970 * 1000
        return currentTime >= expired
    }
    
    func checkNeedRefresh() -> Bool {
        let refresh = UserDefaults.standard.double(forKey: Key.refreshAt.rawValue)
        let currentTime = Date().timeIntervalSince1970 * 1000
        return currentTime >= refresh
    }
    
}

extension URLRequest {

    /**
     Returns a cURL command representation of this URL request.
     */
    public var curlString: String {
        guard let url = url else { return "" }
        var baseCommand = #"curl "\#(url.absoluteString)""#

        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if let method = httpMethod, method != "GET" && method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody, let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }

}
