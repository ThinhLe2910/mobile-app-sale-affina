//
//  EventPopupView.swift
//  affina
//
//  Created by Intelin MacHD on 03/04/2023.
//

import UIKit

class EventPopupView: UIView {
    static let nib = "EventPopupView"
    //MARK: Views
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonView: BaseButton!
    @IBOutlet weak var backButton: UIImageView!
    
    //MARK: Data
    var data: HomeEventModel? {
        didSet {
            if data != nil {
                let url = URL(string: "\(API.STATIC_RESOURCE)\(data!.popupImg ?? "")")
                if url != nil {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let dataImage = try? Data(contentsOf: url!)
                        if dataImage != nil {
                            DispatchQueue.main.async {
                                self.imageView.image = UIImage(data: dataImage!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Callback
    var callback: (() -> Void)?
    var onClose: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    init() {
        super.init(frame: CGRect(origin: .zero, size: .init(width: Constants.Layout.screenWidth, height: Constants.Layout.screenHeight)))
        setupView()
    }
    
    func loadView() {
        Bundle.main.loadNibNamed("EventPopupView", owner: self)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleWidth]
    }
    
    func setupView() {
        loadView()
        containerView.layer.cornerRadius = 16.height
        contentView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.roundCorners([.topLeft,.topRight], radius: 16.height)
        buttonView.backgroundColor = .appColor(.pinkMain)
        buttonView.titleLabel?.font = UIConstants.Fonts.appFont(.Medium, 16)
        buttonView.tintColor = .white
        buttonView.layer.cornerRadius = 16
        buttonView.setTitle("MORE".localize(), for: .normal)
        backButton.backgroundColor = .white.withAlphaComponent(0.5)
        backButton.layer.cornerRadius = 16
        
        //Add touch gesture regconizer
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonTapped)))
        buttonView.addTarget(self, action: #selector(detailButtonTapped), for: .touchUpInside)
        layer.zPosition = 99
        backgroundView.alpha = 0.5
    }
    
    @objc func detailButtonTapped() {
        UIView.animate(withDuration: 0.2, animations: {self.alpha = 0.0}, completion: {(value: Bool) in
            if self.callback == nil {
                self.removeFromSuperview()
                return
            }
            self.callback?()
        })
    }
    
    @objc func backButtonTapped() {
        UIView.animate(withDuration: 0.2, animations: {self.alpha = 0.0}, completion: {(value: Bool) in
            if self.onClose == nil {
                self.removeFromSuperview()
                return
            }
            self.onClose?()
        })
    }
    
    
}
