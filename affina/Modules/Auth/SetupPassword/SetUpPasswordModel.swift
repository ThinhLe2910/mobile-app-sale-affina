//
//  SetUpPasswordModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 23/05/2022.
//

import Foundation

// MARK: Code
enum SetUpPasswordCode: String {
    case OK_200 = "200"
    case AUTH_4001
    case REGISTER_4000 // token expired
}

class SetUpPasswordRequest: BaseApiRequest {
}

struct SetUpPasswordModel: Codable {
    let token: String
    let password: String
}
