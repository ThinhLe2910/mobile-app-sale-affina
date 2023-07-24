//
//  SetUpPasswordViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 20/05/2022.
//

import Foundation

protocol SetupPasswordViewDelegate: AnyObject {
    func lockUI()
    func unlockUI()

    func showErrorPassword(type: PasswordError)

    func updateSuccessful()
    func setupSuccessful()
    
    func setupSuccessfulAfterCreateContract()
}

class SetUpPasswordViewPresenter {
    weak fileprivate var delegate: SetupPasswordViewDelegate?

    private let authService = AuthService()
    
    init() {

    }

    func setViewDelegate(delegate: SetupPasswordViewDelegate?) {
        self.delegate = delegate
    }

    func setupPassword(model: ProfileRegisterModel) {
        delegate?.lockUI()
        authService.setupPassword(model: model) { [weak self] response in
            self?.delegate?.unlockUI()
            switch response {
            case .success(let data):
                Logger.Logs(event: .debug, message: data)
                switch data.code {
                case SetUpPasswordCode.OK_200.rawValue:
                    UserDefaults.standard.set(model.password, forKey: Key.password.rawValue)
                    UserDefaults.standard.set(data.data?.expireAt, forKey: Key.expireAt.rawValue)
                    UserDefaults.standard.set(data.data?.refreshAt, forKey: Key.refreshAt.rawValue)
                    UserDefaults.standard.set(data.data?.token, forKey: Key.token.rawValue)
                    UserDefaults.standard.set(data.data?.profileDetails?.companyId, forKey: Key.companyId.rawValue)
                    UserDefaults.standard.set(data.data?.profileDetails?.cusName, forKey: Key.customerName.rawValue)
                    UserDefaults.standard.set(true, forKey: Key.notFirstTimeLogin.rawValue)
                    let presenter = InputPinCodeViewPresenter()
                    presenter.submitPassword(rsaHashed: model.password, callBack: {
                        
                        self?.delegate?.setupSuccessful()
                    })
                    break
                case SetUpPasswordCode.AUTH_4001.rawValue:

                    break
                case SetUpPasswordCode.REGISTER_4000.rawValue:
                    self?.delegate?.showErrorPassword(type: .expired)
                    break
                default:
                    break
                }
                break
            case .failure(let error):
                Logger.DumpLogs(event: .error, message: error)
                self?.delegate?.showErrorPassword(type: .error)
                break
            }
        }
    }
    
    func submitNewPassword(password: String, token: String) {
        delegate?.lockUI()
        authService.submitNewPassword(password: password, token: token) { [weak self] response in
            self?.delegate?.unlockUI()
            switch response {
            case .success(let data):
                Logger.DumpLogs(event: .debug, message: data)
                switch data.code {
                case ForgotPasswordCode.OK_200.rawValue:
                    UserDefaults.standard.set(password, forKey: Key.password.rawValue)
                    UserDefaults.standard.set(data.data?.token, forKey: Key.token.rawValue)
                    let presenter = InputPinCodeViewPresenter()
                    self?.delegate?.lockUI()
                    presenter.submitPassword(rsaHashed: password, callBack: {
                        self?.delegate?.unlockUI()
                        self?.delegate?.updateSuccessful()
                    })
                    break
                case ForgotPasswordCode.AUTH_4001.rawValue:
                    break
                case ForgotPasswordCode.PASSWORD_4000.rawValue:
                    self?.delegate?.showErrorPassword(type: .expired)
                    break
                default:
                    break
                }
                break
            case .failure(let error):
                Logger.DumpLogs(event: .error, message: error)
                self?.delegate?.showErrorPassword(type: .error)
                break
            }
        }
    }
    
    func setupPasswordAfterCreateContract(body: [String: String]) {
        Logger.Logs(message: body)
        delegate?.lockUI()
        
        authService.setupPasswordAfterCreateContract(body: body) { [weak self] response in
            self?.delegate?.unlockUI()
            switch response {
                case .success(let data):
                    switch data.code {
                        case SetUpPasswordCode.OK_200.rawValue:
                            UserDefaults.standard.set(body["password"], forKey: Key.password.rawValue)
                            UserDefaults.standard.set(data.data?.expireAt, forKey: Key.expireAt.rawValue)
                            UserDefaults.standard.set(data.data?.refreshAt, forKey: Key.refreshAt.rawValue)
                            UserDefaults.standard.set(data.data?.token, forKey: Key.token.rawValue)
                            UserDefaults.standard.set(data.data?.profileDetails?.companyId, forKey: Key.companyId.rawValue)
                            UserDefaults.standard.set(data.data?.profileDetails?.cusName, forKey: Key.customerName.rawValue)
                            UserDefaults.standard.set(true, forKey: Key.notFirstTimeLogin.rawValue)
//                            let presenter = InputPinCodeViewPresenter()
//                            presenter.submitPassword(rsaHashed: model.password, callBack: {
//                                self?.delegate?.setupSuccessful()
//                            })
                            
                            self?.delegate?.setupSuccessfulAfterCreateContract()
                            break
                        case SetUpPasswordCode.AUTH_4001.rawValue:
                            
                            break
                        case SetUpPasswordCode.REGISTER_4000.rawValue:
                            self?.delegate?.showErrorPassword(type: .expired)
                            break
                        default:
                            break
                    }
                    break
                case .failure(let error):
                    Logger.DumpLogs(event: .error, message: error)
                    self?.delegate?.showErrorPassword(type: .error)
                    break
            }
        }
    }
}
