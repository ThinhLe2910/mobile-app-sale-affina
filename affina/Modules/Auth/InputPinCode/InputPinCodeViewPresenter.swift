//
//  InputPinCodeViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/07/2022.
//

import Foundation
import FirebaseMessaging

protocol InputPinCodeViewDelegate: AnyObject {
    func lockUI()
    func unlockUI()

    func showErrorPassword(type: PasswordError)

    func authSuccessfully()
    func accountBanned(isBanned: Bool)
}

class InputPinCodeViewPresenter {
    weak fileprivate var delegate: InputPinCodeViewDelegate?

    private let authService = AuthService()
    
    init() {

    }

    func setViewDelegate(delegate: InputPinCodeViewDelegate?) {
        self.delegate = delegate
    }

    func checkBannedAccount() {
        authService.checkBannedAccount { [weak self] (result: Result<APIResponse<NilData>, ApiError>) in
            self?.delegate?.unlockUI()
            switch result {
            case .success(let data):
                Logger.Logs(event: .debug, message: data)
                switch data.code {
                case CheckPhoneCode.AUTH_4001.rawValue:
//                self?.delegate?.accountBanned(isBanned: true)
                    break
                case CheckPhoneCode.LOGIN_4002.rawValue:
                    self?.delegate?.accountBanned(isBanned: true)
                    break
                case CheckPhoneCode.EXISTED_5000.rawValue:
                    self?.delegate?.accountBanned(isBanned: false)
                    break
                default:
                    self?.delegate?.accountBanned(isBanned: false)
                    break
                }
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func handleSubmitPassword(password: String, isUsingBiometric: Bool) {
        var hashed = ""
        if isUsingBiometric {
            guard let rsaHashed = UserDefaults.standard.string(forKey: Key.password.rawValue) else {
                Logger.Logs(event: .error, message: "Dont save the password")
                return
            }
            hashed = rsaHashed
        }
        else {
            let md5Hashed = HashString.encryptWithMD5(message: password).map { String(format: "%02hhx", $0) }.joined()
            guard let rsaHashed = HashString.encryptWithRsa(message: md5Hashed) else {
                Logger.Logs(event: .error, message: "Hashed Error")
                return
            }
            hashed = rsaHashed
        }

        submitPassword(rsaHashed: hashed)
    }

    func submitPassword(rsaHashed: String, callBack: (() -> Void)? = nil) {
        delegate?.lockUI()
        authService.submitPassword(rsaHashed: rsaHashed) { [weak self] response in
            self?.delegate?.unlockUI()
            switch response {
            case .success(let data):
                Logger.Logs(event: .debug, message: data)
                switch data.code {
                case LoginCode.OK_200.rawValue:
                    UserDefaults.standard.set(rsaHashed, forKey: Key.password.rawValue)
                    UserDefaults.standard.set(data.data?.token, forKey: Key.token.rawValue)
                    UserDefaults.standard.set(data.data?.expireAt, forKey: Key.expireAt.rawValue)
                    UserDefaults.standard.set(data.data?.refreshAt, forKey: Key.refreshAt.rawValue)
                    UserDefaults.standard.set(data.data?.profileDetails?.companyId, forKey: Key.companyId.rawValue)
                    UserDefaults.standard.set(data.data?.profileDetails?.cusName, forKey: Key.customerName.rawValue)
                    UserDefaults.standard.set(true, forKey: Key.notFirstTimeLogin.rawValue)
                    self?.delegate?.authSuccessfully()
                    
                    CommonService().getAllSetup { _ in
                    }
                    CommonService().getConfig { result in
                        switch result {
                            case .success(let response):
                                if let configs = response.data {
                                    for config in configs {
                                        if config.keyName == "hostStaticResource" {
                                            API.STATIC_RESOURCE = config.value
                                        }
                                    }
                                }
                            case .failure(_):
                                Logger.Logs(event: .error, message: "Error")
                        }
                    }
                        
                    Messaging.messaging().subscribe(toTopic: "logged") { error in
                        if let error = error {
                            Logger.Logs(message: error.localizedDescription)
                        }
                    }
                    
                    callBack?()
                    break
                case LoginCode.AUTH_4001.rawValue:
                    self?.delegate?.showErrorPassword(type: .incorrect)
                    break
                case LoginCode.LOGIN_4000.rawValue:
                    self?.delegate?.showErrorPassword(type: .incorrect)
                    break
                case LoginCode.LOGIN_4002.rawValue:
                    self?.delegate?.showErrorPassword(type: .accountBlocked)
                    break
                case LoginCode.LOGIN_5000.rawValue:
                    self?.delegate?.showErrorPassword(type: .error)
                default:
                    break
                }
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                self?.delegate?.showErrorPassword(type: .error)
                break
            }
        }
    }
}

