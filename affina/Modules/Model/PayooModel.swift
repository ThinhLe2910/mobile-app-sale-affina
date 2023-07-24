//
//  PayooModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 16/08/2022.
//

import Foundation

enum PayooMethod: Int {
    case payooEwallet = 1
    case domesticCard = 2
    case internationCard = 4
    case payAtStore = 8
    case token = 16
    case installment = 32
    case qrCode = 64
    case app2App = 128
    case qrPay = 512
    case unSelected = 256
    
    var value: NSNumber {
        return self.rawValue as NSNumber
    }
}


//enum PaymentMethod: Int {
//    case POSTPAID
//    case PAYOO
//}

enum PaymentMethod: Int {
    case internationalCard = 2
    case domesticCard = 3
    case paymentLater = 4
    case installment = 6
    
    static func getPaymentMethod(by payooMethod: PayooMethod) -> PaymentMethod{
        switch payooMethod {
            case .domesticCard:
                return .domesticCard
            case .internationCard:
                return .internationalCard
            case .payAtStore:
                return .paymentLater
            case .installment:
                return .installment
//            case .payooEwallet:
//                <#code#>
//            case .token:
//                <#code#>
//            case .qrCode:
//                <#code#>
//            case .app2App:
//                <#code#>
//            case .qrPay:
//                <#code#>
//            case .unSelected:
//                <#code#>
            default:
                return .domesticCard
        }
    }
}
