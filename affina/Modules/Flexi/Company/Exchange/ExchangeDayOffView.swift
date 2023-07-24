//
//  ExchangeDayOffView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 03/03/2023.
//

import UIKit

class ExchangeDayOffView: UIView {

    static let nib = "ExchangeDayOffView"
    
    @IBOutlet weak var containerView: BaseView!
    
    @IBOutlet weak var submitButton: BaseButton!
    @IBOutlet weak var cancelButton: BaseButton!
    
    @IBOutlet weak var dayOffSlider: UISlider!
    @IBOutlet weak var dayOffLabel: BaseLabel!
    
    @IBOutlet weak var availableDayOffLabel: BaseLabel!
    
    @IBOutlet weak var moneyLabel: BaseLabel!
    
    var submitCallBack: ((Int) -> Void)?
    var cancelCallBack: (() -> Void)?
    var point: Int = 0
    var usedDay: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    var maxDay: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    private var dayAmount = 0
    
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
        Bundle.main.loadNibNamed(ExchangeDayOffView.nib, owner: self, options: nil)
        addSubview(containerView)
        
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        //        containerView.backgroundColor = .clear
        
        containerView.addTapGestureRecognizer {
            self.endEditing(true)
        }
        
        dayOffSlider.tintColor = .appColor(.blueMain)
        dayOffSlider.addTarget(self, action: #selector(valueDidChange(_:)), for: .valueChanged)
        //        heartSlider.layer.cornerRadius = 4
        //        heartSlider.layer.masksToBounds = true
        dayOffSlider.maximumTrackTintColor = .appColor(.blueSlider)
        
        moneyLabel.text = "0 đ"
        
        submitButton.addTapGestureRecognizer {
            self.submitCallBack?(self.dayAmount)
        }
        
        cancelButton.addTapGestureRecognizer {
            self.cancelCallBack?()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    private func updateUI() {
        let availDay = maxDay - usedDay
        availableDayOffLabel.text = "\("AVAILABLE".localize()) \(availDay) ngày"
        
        dayOffSlider.maximumValue = Float(availDay)
        dayOffSlider.minimumValue = 0
        
        if availDay == 0 {
            submitButton.disable()
        }
        else {
            submitButton.enable()
        }
    }
    
    @objc private func valueDidChange(_ sender: UISlider) {
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        dayAmount = Int(roundedValue)
        dayOffLabel.text = "\(dayAmount)"
        moneyLabel.text = "\((dayAmount * point).addComma()) đ"
    }
}
