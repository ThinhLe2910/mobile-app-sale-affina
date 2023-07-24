//
//  PaymentManager.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 23/08/2022.
//

import Foundation
import PayooPayment
import PayooCore
import UIKit

class PaymentManager {
    static let shared: PaymentManager = PaymentManager()
    
    private init() {
        Logger.Logs(message: API.networkEnvironment == .live ? "production" : "development")
        Configuration.set(environment: API.networkEnvironment == .live ? .production : .development)
        Configuration.set(merchantId: UIConstants.merchantID, secretKey: UIConstants.secretKey)
        Appearance.navigationBarBackgroundColor = UIColor.appColor(.pinkMain) ?? UIColor.white
        Appearance.backgroundColor = UIColor.appColor(.pinkMain) ?? UIColor.white
    }
    
    func getInsurancePaymentConfig(contract: InsuranceContractModel, paymentType: PayooMethod) -> PaymentConfiguration {
        let paymentConfig = PaymentConfiguration(
            //            authToken: "",
            defaultCustomerEmail: contract.buyEmail,
            defaultCustomerPhone: contract.buyPhone,
            //            userId: "", // userIdTextField.text,
            supportedPaymentMethods: paymentType.value, // Int(supportedMethodsTextField.text!) as NSNumber? ?? 255,
            //            bankCode: "",// bankCodeTextField.text,
            supportedPeriod: contract.periodValue as NSNumber
        )
        return paymentConfig
    }
    
    func pay(orderRequest: OrderRequest, paymentConfig: PaymentConfiguration, viewController: UIViewController, completion: @escaping ((GroupType, PaymentResponseObject?) -> Void)) {
        let paymentContext = PaymentContext(configuration: paymentConfig) { (status, data) in
            completion(status, data)
        }
        
        paymentContext.selectMethod(orderRequest: orderRequest, from: viewController)
        //        paymentContext.pay(orderRequest: orderRequest, from: self)
    }
    
}
