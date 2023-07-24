//
//  InsuranceApproachViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 09/08/2022.
//

import UIKit

class InsuranceApproachViewController: BaseViewController {

    @IBOutlet weak var backButton: BaseButton!
    
    @IBOutlet weak var personView: BaseView!
    @IBOutlet weak var groupView: BaseView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideHeaderBase()
        containerBaseView.hide()
        
        addBlurStatusBar()
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        personView.addTapGestureRecognizer {
            self.navigationController?.pushViewController(InsuranceFilterViewController(), animated: true)
        }
        
        groupView.isUserInteractionEnabled = false
        groupView.layer.opacity = 0.5
        groupView.addTapGestureRecognizer {
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
    }

    @objc private func didTapBackButton() {
//        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
