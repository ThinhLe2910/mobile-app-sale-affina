//
//  CartViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 19/08/2022.
//

import UIKit

class CartViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideHeaderBase()
        containerBaseView.hide()
        view.backgroundColor = .appColor(.blueUltraLighter)
        
        addBlurStatusBar()
        
    }
    
    
}
