//
//  InsurancePaymentViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 14/08/2022.
//

import UIKit
import PayooPayment
import PayooCore

protocol InsurancePaymentViewDelegate {
    func lockUI()
    func unLockUI()
    
    func updateSuccessful(contract: InsuranceContractModel)
    
    func showAlert(message: String)
    func showError(error: ApiError)
    
    func handleCheckVoucherError(code: String, message: String)
    func handlePayooStatus(status: GroupType, data: PaymentResponseObject)
    
    func handleSmartpayOrder(order: SmartpayOrderModel)
}

class InsurancePaymentViewPresenter {
    var delegate: InsurancePaymentViewDelegate?
    
    init() {}
    
    func setViewDelegate(delegate: InsurancePaymentViewDelegate) {
        self.delegate = delegate
    }
    
    func updateContract(model: PaymentContractRequestModel) {
        delegate?.lockUI()
        Logger.Logs(message: model.dictionary)
        let body: Data? = try? JSONSerialization.data(withJSONObject: model.dictionary, options: [])
        let request = BaseApiRequest(path: API.Contract.CREATE_CONTRACT, method: .put, parameters: [:], isJsonRequest: true, headers: [:], httpBody: body)
        APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<InsuranceContractModel>, ApiError>) in
            self?.delegate?.unLockUI()
            switch result {
                case .success(let data):
                    guard let model = data.data else {
                        return
                    }
                    Logger.Logs(message: model)
                    self?.delegate?.updateSuccessful(contract: model)
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error.localizedDescription)
                    if error.localizedDescription.contains("The operation couldn’t be completed. (affina.ApiError error 1.)") {
                        self?.delegate?.showError(error: .noInternetConnection)
                    }
                    else {
                        self?.delegate?.showError(error: .otherError)
                    }
            }
        }
    }
    
    func updateContractWithToken(model: PaymentContractRequestModel) {
        delegate?.lockUI()
        Logger.Logs(message: model.dictionary)
        let body: Data? = try? JSONSerialization.data(withJSONObject: model.dictionary, options: [])
        let request = BaseApiRequest(path: API.Contract.CREATE_CONTRACT_WITH_TOKEN, method: .put, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<InsuranceContractModel>, ApiError>) in
            self?.delegate?.unLockUI()
            switch result {
                case .success(let data):
                    guard let model = data.data else {
                        return
                    }
                    Logger.Logs(message: model)
                    self?.delegate?.updateSuccessful(contract: model)
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error.localizedDescription)
                    if error.localizedDescription.contains("The operation couldn’t be completed. (affina.ApiError error 1.)") {
                        self?.delegate?.showError(error: .noInternetConnection)
                    }
                    else {
                        switch error {
                        case ApiError.invalidData(let error, let data):
                            Logger.Logs(message: error)
                            guard let data = data else { return }
                            do {
                                let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                                if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                                    self?.delegate?.showError(error: ApiError.expired)
                                }
                                else if nilData.code == "VOUCHER_4004" {
                                    self?.delegate?.handleCheckVoucherError(code: nilData.code, message: nilData.messages ?? "")
                                }
                            }
                            catch let err{
                                Logger.DumpLogs(event: .error, message: err)
                            }
                            
                        default:
                            self?.delegate?.showError(error: error)
                            break
                        }
                    }
            }
        }
    }
    
    func payWithPayoo(contract: InsuranceContractModel, paymentType: PayooMethod, viewController: BaseViewController) {
        
        let orderRequest = OrderRequest(orderInfo: contract.payooOrder!, checksum: contract.payooChecksum!, cashAmount: Double(contract.amountPay))
        PaymentManager.shared.pay(orderRequest: orderRequest, paymentConfig: PaymentManager.shared.getInsurancePaymentConfig(contract: contract, paymentType: paymentType), viewController: viewController) { [weak self] status, data in
            guard let data = data else {
                Logger.Logs(message: "Failure, data is null")
                return
            }
            self?.delegate?.handlePayooStatus(status: status, data: data)
        }
        //        self.pay(orderRequest: orderRequest, paymentConfig: PaymentManager.shared.getInsurancePaymentConfig(contract: contract, paymentType: paymentType))
        
    }
    
    func getSmartpayStatusOrder(transactionId: String) {
        let fields: [String: String] = ["transactionId": transactionId]
        let body: Data? = try? JSONEncoder().encode(fields)
        let request = BaseApiRequest(path: API.Contract.GET_STATUS_ORDER_SMARTPAY, method: .post, parameters: [:], isJsonRequest: false, headers: [:], httpBody: body)
        APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<SmartpayOrderModel>, ApiError>) in
            switch result {
                case .success(let data):
                    Logger.Logs(message: data)
                    guard let data = data.data else { return }
                    self?.delegate?.handleSmartpayOrder(order: data)
                case .failure(let error):
                    Logger.Logs(message: error)
            }
            
        }
    }
    
//    let orderRequest = OrderRequest(orderInfo: contract.payooOrder!, checksum: contract.payooChecksum!, cashAmount: Double(contract.amountPay))
//    PaymentManager.shared.pay(orderRequest: orderRequest, paymentConfig: PaymentManager.shared.getInsurancePaymentConfig(contract: contract, paymentType: paymentType), viewController: self) { [weak self] status, data in
//        guard let data = data else {
//            Logger.Logs(message: "Failure, data is null")
//            return
//        }
//        switch status {
//            case .success:
//                Logger.Logs(message: "Success \(String(describing: data.message)) (\(data.code))")
//                
//            case .failure:
//                Logger.Logs(message: "Failure \(String(describing: data.message)) (\(data.code))")
//                self?.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "PAYMENT_FAILED".localize(),
//                                     desc: "Lỗi {\(String(describing: data.message ?? "Không thể xác định"))}, vui lòng thử lại",
//                                     okTitle: "TRY_AGAIN".localize(), cancelTitle: "") {
//                    self?.hideBasePopup()
//                } handler: {
//                }
//            case .unknown:
//                Logger.Logs(message: "Unknown \(String(describing: data.message)) (\(data.code))")
//                self?.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "PAYMENT_FAILED".localize(),
//                                     desc: "Lỗi {\(String(describing: data.message ?? "Không thể xác định"))}, vui lòng thử lại",
//                                     okTitle: "TRY_AGAIN".localize(), cancelTitle: "") {
//                    self?.hideBasePopup()
//                } handler: {
//                }
//            case .cancel:
//                Logger.Logs(message: "Cancel! Cancelled by user.")
//                self?.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "PAYMENT_FAILED".localize(),
//                                     desc: "Lỗi {\(String(describing: data.message ?? "Không thể xác định"))}, vui lòng thử lại",
//                                     okTitle: "TRY_AGAIN".localize(), cancelTitle: "") {
//                    self?.hideBasePopup()
//                } handler: {
//                }
//            @unknown default:
//                Logger.Logs(message: "Unknown Default")
//        }
//    }
    //        self.pay(orderRequest: orderRequest, paymentConfig: PaymentManager.shared.getInsurancePaymentConfig(contract: contract, paymentType: paymentType))
    
}
