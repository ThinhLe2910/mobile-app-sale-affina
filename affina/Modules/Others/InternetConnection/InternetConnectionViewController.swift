//
//  InternetConnectionViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 16/05/2022.
//

import UIKit

class InternetConnectionViewController: BaseViewController {

    private var presenter: InternetConnectionPresenterDelegate?
    
    private lazy var buttonDismiss: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = InternetConnectionPresenter(self)
        
        initViews()
    }
    
    override func initViews() {
        
        hideLeftBaseButton()
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(UIConstants.Layout.screenWidth)
            make.height.equalTo(UIConstants.Layout.screenHeight)
        }
        imageView.image = UIImage()
        
        view.addSubview(buttonDismiss)
        buttonDismiss.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(UIConstants.Layout.screenHeight - 200)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        buttonDismiss.center.x = containerBaseView.center.x
        buttonDismiss.layer.cornerRadius = 5
        buttonDismiss.setTitle("Retry".localize(), for: .normal)
        buttonDismiss.addTarget(self, action: #selector(retry), for: .touchUpInside)
    }
    
    @objc private func retry() {
        presenter?.checkCurrentToken()
    }

    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }

}
