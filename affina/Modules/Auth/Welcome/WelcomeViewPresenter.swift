//
//  WelcomeViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/07/2022.
//

import Foundation

protocol WelcomeViewDelegate: AnyObject {
    func lockUI()
    func unlockUI()

    func showErrorPhone(type: PasswordError)

    func goToRegister()
    func goToLogin()
    func authSuccessfully()
}

class WelcomeViewPresenter {
    weak fileprivate var delegate: WelcomeViewDelegate?

    private let authService = AuthService()
    
    init() {

    }

    func setViewDelegate(delegate: WelcomeViewDelegate?) {
        self.delegate = delegate
    }

    func handleSubmitPhone(phoneNumber: String) {
        delegate?.lockUI()
        authService.handleSubmitPhone(phoneNumber: phoneNumber) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case .success(let data):
                Logger.DumpLogs(event: .debug, message: data)
                switch data.code {
                case CheckPhoneCode.LOGIN_2001.rawValue:
                    UserDefaults.standard.set(phoneNumber, forKey: Key.phoneNumber.rawValue)
                    self?.delegate?.goToRegister()
                    break
                case CheckPhoneCode.LOGIN_4002.rawValue:
                    self?.delegate?.showErrorPhone(type: .accountBlocked)
                    break
                case CheckPhoneCode.OK_200.rawValue:
                    UserDefaults.standard.set(phoneNumber, forKey: Key.phoneNumber.rawValue)
                    self?.delegate?.goToLogin()
                    break
                case CheckPhoneCode.AUTH_4001.rawValue:
                    break
                case CheckPhoneCode.EXISTED_5000.rawValue:
                    self?.delegate?.showErrorPhone(type: .error)
//                    self?.delegate?.goToLogin()
                    break
                default:
                    break
                }
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                switch error {
                case ApiError.invalidData(let error, let data):
                    Logger.Logs(message: error)
                    guard let data = data else { return }
                    do {
                        let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                        if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                            self?.delegate?.showErrorPhone(type: .accountBlocked)
                        }
                    }
                    catch let err{
                        Logger.DumpLogs(event: .error, message: err)
                    }
                    
                default:
                    break
                }
                
                break
            }
        }
    }
}
