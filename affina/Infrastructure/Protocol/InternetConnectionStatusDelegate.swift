//
//  InternetConnectionStatusDelegate.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import UIKit

protocol InternetConnectionStatusDelegate: AnyObject {
    func showViewDisconnected()
    func badRequest()
    func tokenExpired()
    func tokenNotFound()
}
