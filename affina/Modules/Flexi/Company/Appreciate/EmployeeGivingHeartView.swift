//
//  EmployeeGivingHeartView.swift
//  affina
//
//  Created by Dylan on 24/10/2022.
//

import UIKit

class EmployeeGivingHeartView: BaseView {
    static let nib = "EmployeeGivingHeartView"
    
    @IBOutlet weak var containerView: BaseView!
    
    @IBOutlet weak var defaultImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var submitButton: BaseButton!
    @IBOutlet weak var cancelButton: BaseButton!
    
    @IBOutlet weak var noteTextField: TitleTextFieldBase!
    
    @IBOutlet weak var heartSlider: UISlider!
    
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var positionLabel: BaseLabel!
    
    @IBOutlet weak var maxHeartLabel: BaseLabel!
    @IBOutlet weak var donatingHeartLabel: BaseLabel!
    
    var submitCallBack: (() -> Void)?
    var cancelCallBack: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(EmployeeGivingHeartView.nib, owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        containerView.backgroundColor = .clear
        
        containerView.addTapGestureRecognizer {
            self.endEditing(true)
        }
        
        heartSlider.tintColor = .appColor(.blueMain)
//        heartSlider.layer.cornerRadius = 4
//        heartSlider.layer.masksToBounds = true
        heartSlider.maximumTrackTintColor = .appColor(.blueSlider)
        
        noteTextField.titleLabel.font = UIConstants.Fonts.appFont(.Bold, 14)
        noteTextField.textField.font = UIConstants.Fonts.appFont(.Medium, 16)
        
        let pointText = "Số điểm: 200 "
        let attrs = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16)
        ] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: pointText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: "tim")
        attributedString.append(normalString)
        donatingHeartLabel.attributedText = attributedString
        
        
        submitButton.addTapGestureRecognizer {
            self.submitCallBack?()
        }
        
        cancelButton.addTapGestureRecognizer {
            self.cancelCallBack?()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
