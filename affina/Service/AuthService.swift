//
//  AuthService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 01/03/2023.
//

import Foundation

class AuthService {
    
    func checkBannedAccount(completion: @escaping ((Result<APIResponse<NilData>, ApiError>) -> Void)) {
        let phoneNumber = UserDefaults.standard.string(forKey: Key.phoneNumber.rawValue) ?? ""
        let request = LoginRequest(path: API.User.CHECK_PHONE_NUMBER, method: .get, parameters: ["phone": phoneNumber], isJsonRequest: false, headers: [:], httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NilData>, ApiError>) in
            completion(result)
        }
    }
    
    func submitPassword(rsaHashed: String, completion: @escaping ((Result<APIResponse<UserAuthResponseData>, ApiError>) -> Void)) {
        let phoneNumber = UserDefaults.standard.string(forKey: Key.phoneNumber.rawValue) ?? ""
        let pushKey = UserDefaults.standard.string(forKey: Key.pushKey.rawValue) ?? ""
        let model = LoginModel(username: phoneNumber, password: rsaHashed, pushKey: pushKey)
        
        let body: Data? = try? JSONEncoder().encode(model)
        let request = LoginRequest(path: API.User.LOGIN, method: .post, parameters: [:], isJsonRequest: true, headers: [:], httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<UserAuthResponseData>, ApiError>) in
                completion(result)
        }
    }
    
    func handleSubmitPhone(phoneNumber: String, completion: @escaping ((Result<APIResponse<NilData>, ApiError>) -> Void)) {
        let request = LoginRequest(path: API.User.CHECK_PHONE_NUMBER, method: .get, parameters: ["phone": phoneNumber], isJsonRequest: false, headers: [:], httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NilData>, ApiError>) in
            completion(result)
        }
    }
    
    func submitOtp(otp: OtpModel, completion: @escaping ((Result<APIResponse<OtpSubmitData>, ApiError>) -> Void)) {
        var rawJson: Data?
        do {
            rawJson = try JSONEncoder().encode(otp)
        } catch { }
        
        let request = OtpRequest(path: API.User.SUBMIT_OTP, method: .put, parameters: [:], isJsonRequest: true, headers: [:], httpBody: rawJson)
        APIManager.shared.send2(request: request) { (response: Result<APIResponse<OtpSubmitData>, ApiError>) in
            completion(response)
        }
    }
    
    func requestOtpForgot(phoneNumber: String, completion: @escaping ((Result<APIResponse<OtpResponseData>, ApiError>) -> Void)) {
        let request = OtpRequest(path: API.User.GET_OTP_FORGOT_PASSWORD, method: .get, parameters: ["phone":phoneNumber], isJsonRequest: false, headers: [:], httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<OtpResponseData>, ApiError>) in
            completion(result)
        }
    }
    
    func requestOtpRegister(phoneNumber: String, completion: @escaping ((Result<APIResponse<OtpResponseData>, ApiError>) -> Void)) {
        let request = OtpRequest(path: API.User.GET_OTP_REGISTER, method: .get, parameters: ["phone": phoneNumber], isJsonRequest: false, headers: [:], httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<OtpResponseData>, ApiError>) in
            completion(result)
        }
    }
    
    func resendOtp(otpKey: String, completion: @escaping ((Result<APIResponse<OtpResendResponseData>, ApiError>) -> Void)) {
        let body = ["otpKey": otpKey]
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        let request = OtpRequest(path: API.User.SUBMIT_OTP, method: .delete, parameters: [:], isJsonRequest: true, headers: [:], httpBody: data)
        APIManager.shared.send2(request: request) { (response: Result<APIResponse<OtpResendResponseData>, ApiError>) in
            completion(response)
        }
    }
    
    func setupPassword(model: ProfileRegisterModel, completion: @escaping ((Result<APIResponse<UserAuthResponseData>, ApiError>) -> Void)) {

        let data: Data? = try? JSONSerialization.data(withJSONObject: model.dictionary, options: [])
        let request = SetUpPasswordRequest(path: API.User.REGISTER_ACCOUNT, method: .post, parameters: [:], isJsonRequest: true, headers: [:], httpBody: data)
        
        APIManager.shared.send2(request: request) { (response: Result<APIResponse<UserAuthResponseData>, ApiError>) in
            completion(response)
        }
    }
    
    
    func submitNewPassword(password: String, token: String, completion: @escaping ((Result<APIResponse<UserAuthResponseData>, ApiError>) -> Void)) {
        let model = ForgotPasswordModel(token: token, password: password)
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: model.dictionary, options: [])
        let request = ForgotPasswordRequest(path: API.User.FORGOT_PASSWORD, method: .post, parameters: [:], isJsonRequest: true, headers: [:], httpBody: data)
        APIManager.shared.send2(request: request) { (response: Result<APIResponse<UserAuthResponseData>, ApiError>) in
            completion(response)
        }
    }
    
    func setupPasswordAfterCreateContract(body: [String: String], completion: @escaping ((Result<APIResponse<UserAuthResponseData>, ApiError>) -> Void)) {
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        let request = BaseApiRequest(path: API.Contract.REGISTER_AFTER_CREATE_CONTRACT, method: .post, parameters: [:], isJsonRequest: true, headers: [:], httpBody: data)
        APIManager.shared.send2(request: request) { (response: Result<APIResponse<UserAuthResponseData>, ApiError>) in
            completion(response)
        }
    }
}
