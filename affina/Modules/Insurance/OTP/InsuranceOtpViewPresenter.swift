//
//  InsuranceOtpViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 20/05/2022.
//

import Foundation

protocol InsuranceOtpViewDelegate: AnyObject {
    func lockUI()
    func unlockUI()

    func showErrorOtp(type: OtpError)

    func showAlert()

    func authSuccessful(contract: InsuranceContractModel)

    func updateOtpKey(otpKey: String, type: Int, contact: String, time: Double)
}

class InsuranceOtpViewPresenter {
    weak fileprivate var delegate: InsuranceOtpViewDelegate?

    init() {
    }

    func setViewDelegate(delegate: InsuranceOtpViewDelegate?) {
        self.delegate = delegate
    }

    func submitOtp(otp: OtpModel) {
        delegate?.lockUI()

        let body = ["otpKey": otp.otpKey, "code": otp.code]
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        let request = OtpRequest(path: API.User.SUBMIT_OTP, method: .put, parameters: [:], isJsonRequest: true, headers: [:], httpBody: data)
        APIManager.shared.send2(request: request) { [weak self] (response: Result<APIResponse<InsuranceContractModel>, ApiError>) in
            self?.delegate?.unlockUI()
            switch response {
            case.success(let data):
                Logger.Logs(event: .debug, message: data)
                switch data.code {
                case OtpCode.OK_200.rawValue:
                    guard let data = data.data else { return }
                    self?.delegate?.authSuccessful(contract: data)
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
    func resendOtp(otpKey: String) {
        delegate?.lockUI()
        let body = ["otpKey": otpKey]
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        let request = OtpRequest(path: API.User.SUBMIT_OTP, method: .delete, parameters: [:], isJsonRequest: true, headers: [:], httpBody: data)
        APIManager.shared.send2(request: request) { [weak self] (response: Result<APIResponse<OtpResendResponseData>, ApiError>) in
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
