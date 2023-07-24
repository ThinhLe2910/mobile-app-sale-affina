//
//  OtpViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 20/05/2022.
//

import Foundation

protocol OtpViewDelegate: AnyObject {
    func lockUI()
    func unlockUI()

    func showErrorOtp(type: OtpError)

    func showAlert()

    func authSuccessful(token: String)

    func updateOtpKey(otpKey: String, type: Int, contact: String, time: Double)
}

class OtpViewPresenter {
    weak fileprivate var delegate: OtpViewDelegate?

    private let authService = AuthService()
    
    init() {
    }

    func setViewDelegate(delegate: OtpViewDelegate?) {
        self.delegate = delegate
    }

    func submitOtp(otp: OtpModel) {
        delegate?.lockUI()
        authService.submitOtp(otp: otp) { [weak self] response in
            self?.delegate?.unlockUI()
            switch response {
            case.success(let data):
                Logger.DumpLogs(event: .debug, message: data)
                switch data.code {
                case OtpCode.OK_200.rawValue:
                    self?.delegate?.authSuccessful(token: data.data?.token ?? "")
                    break
                case OtpCode.OTP_4000.rawValue:
                    self?.delegate?.showErrorOtp(type: .unmatch)
                    break
                case OtpCode.OTP_4001.rawValue:
                    self?.delegate?.showErrorOtp(type: .expired)
                    break
                case OtpCode.OTP_4002.rawValue:
                    self?.delegate?.showErrorOtp(type: .failed)
                    break
                case OtpCode.OTP_4003.rawValue:
                    self?.delegate?.showErrorOtp(type: .wrongManyTime)
                    break
                case OtpCode.AUTH_4001.rawValue:
                    break
                default:
                    break
                }
            case .failure(let error):
                Logger.DumpLogs(event: .error, message: error)
                self?.delegate?.showErrorOtp(type: .error)
            }
        }
    }

    func requestOtpForgot(phoneNumber: String) {
        delegate?.lockUI()
        authService.requestOtpForgot(phoneNumber: phoneNumber) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case .success(let data):
                Logger.DumpLogs(event: .debug, message: data)
                switch data.code {
                case OtpCode.OK_200.rawValue:
                        self?.delegate?.updateOtpKey(otpKey: data.data?.otpKey ?? "", type: data.data?.via ?? 2, contact: data.data?.contact ?? "", time: (data.data?.timeCodeExpire ?? 0) / 1000)
                    break
                case OtpCode.OTP_4004.rawValue:
                    self?.delegate?.showErrorOtp(type: .requestLimited)
                    break
                case OtpCode.AUTH_4001.rawValue:
                    break
                case OtpCode.OTP_4002.rawValue:
                    break
                case LoginCode.LOGIN_4002.rawValue:
                    self?.delegate?.showErrorOtp(type: .blocked)
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
                        if nilData.code == LoginCode.LOGIN_4002.rawValue {
                            self?.delegate?.showErrorOtp(type: .blocked)
                        }
                        else if nilData.code == OtpCode.OTP_4004.rawValue {
                            self?.delegate?.showErrorOtp(type: .requestLimited)
                        }
                        else {
                            self?.delegate?.showErrorOtp(type: .error)
                        }
                    }
                    catch let err{
                        Logger.Logs(event: .error, message: err)
                        self?.delegate?.showErrorOtp(type: .error)
                    }
                    
                default:
                    self?.delegate?.showErrorOtp(type: .error)
                    break
                }
            }
        }
    }

    func requestOtpRegister(phoneNumber: String) {
        delegate?.lockUI()
        authService.requestOtpRegister(phoneNumber: phoneNumber) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case .success(let data):
                Logger.DumpLogs(event: .debug, message: data)
                switch data.code {
                case OtpCode.OK_200.rawValue:
                    self?.delegate?.updateOtpKey(otpKey: data.data?.otpKey ?? "", type: data.data?.via ?? 2, contact: data.data?.contact ?? "", time: (data.data?.timeCodeExpire ?? 0) / 1000)
                    break
                case OtpCode.OTP_4004.rawValue:
                    self?.delegate?.showErrorOtp(type: .requestLimited)
                    break
                case OtpCode.AUTH_4001.rawValue:
                    break
                default:
                    break
                }
            case .failure(let error):
                Logger.DumpLogs(event: .error, message: error)
                switch error {
                case ApiError.invalidData(let error, let data):
                    Logger.Logs(message: error)
                    guard let data = data else { return }
                    do {
                        let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                        if nilData.code == OtpCode.OTP_4004.rawValue {
                            self?.delegate?.showErrorOtp(type: .requestLimited)
                        }
                    }
                    catch let err{
                        Logger.Logs(event: .error, message: err)
                    }
                    
                default:
                    self?.delegate?.showErrorOtp(type: .error)
                    break
                }
            }
        }
    }

    func resendOtp(otpKey: String) {
        delegate?.lockUI()
        authService.resendOtp(otpKey: otpKey) { [weak self] response in
            self?.delegate?.unlockUI()
            switch response {
            case .success(let data):
                Logger.Logs(event: .debug, message: data)
                switch data.code {
                case OtpCode.AUTH_4002.rawValue:
                    self?.delegate?.showErrorOtp(type: .expired)
                    break
                case OtpCode.OK_200.rawValue:
                    self?.delegate?.updateOtpKey(otpKey: data.data?.otpKey ?? "", type: -1, contact: "", time: (data.data?.timeCodeExpire ?? 0) / 1000)
                    break
                default:
                    break
                }
                break
            case .failure(let error):
                Logger.DumpLogs(event: .error, message: error)
                switch error {
                case ApiError.invalidData(let error, let data):
                    Logger.Logs(message: error)
                    guard let data = data else { return }
                    do {
                        let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                        if nilData.code == OtpCode.OTP_4004.rawValue {
                            self?.delegate?.showErrorOtp(type: .requestLimited)
                        }
                        else if nilData.code == LoginCode.LOGIN_4002.rawValue {
                            self?.delegate?.showErrorOtp(type: .blocked)
                        }
                    }
                    catch let err{
                        Logger.Logs(event: .error, message: err)
                    }
                    
                default:
                    self?.delegate?.showErrorOtp(type: .error)
                    break
                }
                break
            }
        }
    }
}
