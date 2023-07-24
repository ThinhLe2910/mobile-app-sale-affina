//
//  NotificationSettingView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 20/07/2022.
//

import UIKit

class NotificationSettingView: UIView {
    
    static let nib = "NotificationSettingView"
    
    class func instanceFromNib() -> NotificationSettingView {
        return UINib(nibName: NotificationSettingView.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NotificationSettingView
    }
    
    @IBOutlet weak var contentView: BaseView!
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var doneButton: BaseButton!
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var pushNotiSwitch: UISwitch!
    
    var closeCallBack: (() -> Void)?
    var emailCallBack: ((Bool) -> Void)?
    var pushCallBack: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(NotificationSettingView.nib, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        contentView.backgroundColor = .clear
        
        roundCorners([.topLeft, .topRight], radius: 20)
        
        doneButton.addTapGestureRecognizer {
            self.closeCallBack?()
        }
        
        emailSwitch.onTintColor = .appColor(.blueMain)
        pushNotiSwitch.onTintColor = .appColor(.blueMain)
        emailSwitch.addTarget(self, action: #selector(valueEmailSwitchChanged), for: .valueChanged)
        pushNotiSwitch.addTarget(self, action: #selector(valuePushNotiSwitchChanged), for: .valueChanged)
    }
    
    @objc private func valueEmailSwitchChanged() {
        emailCallBack?(emailSwitch.isOn)
    }
    
    @objc private func valuePushNotiSwitchChanged() {
        pushCallBack?(pushNotiSwitch.isOn)
    }
    
    func setData(model: SettingCellModel) {
        titleLabel.text = model.title
        emailSwitch.isOn = model.subText.isEmpty ? false : (model.subText.contains("EMAIL".localize()))
        pushNotiSwitch.isOn = model.subText.isEmpty ? false : (model.subText.contains("PUSH_NOTIFICATION".localize()))
    }
}
