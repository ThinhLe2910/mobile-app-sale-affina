//
//  BaseNavigationController.swift
//  affina
//
//  Created by Intelin MacHD on 06/04/2023.
//

import UIKit

class BaseNavigationController: UINavigationController {
    var onDismissCallback: (()->())?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismissCallback?()
    }
}
