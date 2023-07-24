//
//  InternetConnectionPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 16/05/2022.
//

import UIKit

protocol InternetConnectionPresenterDelegate {
    func checkCurrentToken()
}

class InternetConnectionPresenter: InternetConnectionPresenterDelegate {
    
    var viewController: InternetConnectionViewController?
    var password: String = ""
    
    init(_ view: InternetConnectionViewController) {
        viewController = view
    }
    
    func checkCurrentToken() {
        
    }
}
