//
//  CardCompensationHistoryHeaderView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 14/07/2022.
//

import UIKit

class CardCompensationHistoryHeaderView: UITableViewHeaderFooterView {
    static let nib = "CardCompensationHistoryHeaderView"
    static let headerId = "CardCompensationHistoryHeaderView"
    
    class func instanceFromNib() -> CardCompensationHistoryHeaderView {
        return UINib(nibName: CardCompensationHistoryHeaderView.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CardCompensationHistoryHeaderView
    }
    
    @IBOutlet weak var yearLabel: BaseLabel!
    @IBOutlet weak var calendarButton: BaseButton!
    @IBOutlet weak var categoryView: BaseView!
    @IBOutlet weak var categoryTitle: BaseLabel!
    @IBOutlet weak var categoryStateIcon: UIImageView!
    @IBOutlet weak var categoryTextField: TextFieldAnimBase!
    
    let statePickerView: UIPickerView = UIPickerView()
    
    private let states: [Int] = [
        -1,
        ClaimProcessType.PROCESSING.rawValue,
        ClaimProcessType.SENT_INFO.rawValue,
        ClaimProcessType.REQUIRE_UPDATE.rawValue,
        ClaimProcessType.APPROVED.rawValue,
        ClaimProcessType.REJECT.rawValue
    ]
    
    private let stateStrings: [String] = [
        "ALL".localize(),
        ClaimProcessType.PROCESSING.string,
        ClaimProcessType.SENT_INFO.string,
        ClaimProcessType.REQUIRE_UPDATE.string,
        ClaimProcessType.APPROVED.string,
        ClaimProcessType.REJECT.string
    ]
    
    private let stateIcons: [String] = [
        "ic_circle",
        "ic_processing_state",
        "ic_new_state",
        "ic_update_state",
        "ic_approved_state",
        "ic_reject_state",
    ]
    
    var textFieldResponderCallback: (() -> Void)?
    var didFilterState: ((Int) -> Void)?
    
    var selectedRow: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addTapGestureRecognizer {
            self.endEditing(true)
        }
        
        categoryTextField.delegate = self
        
        categoryView.isUserInteractionEnabled = true
        categoryView.addTapGestureRecognizer {
            self.textFieldResponderCallback?()
        }
        
        statePickerView.delegate = self
        setupViewPicker(pickerView: statePickerView, textField: categoryTextField)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func showFilterButton() {
        categoryView.isHidden = false
    }
    
    func hideFilterButton() {
        categoryView.isHidden = true
    }
    
    func setStatusFilter(_ status: Int) {
        categoryTitle.text = stateStrings[status]
        categoryStateIcon.image = UIImage(named: stateIcons[status])
        
    }
}

extension CardCompensationHistoryHeaderView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTitle.text = stateStrings[row]
        categoryStateIcon.image = UIImage(named: stateIcons[row])
        selectedRow = row
        Logger.Logs(message: selectedRow)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stateStrings[row]
    }
    
    private func setupViewPicker(pickerView: UIPickerView, textField: TextFieldAnimBase) {
        //        pickerView.backgroundColor = UIColor.appColor(.whiteMain)
        
        textField.inputView = pickerView
        let doneToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "DONE".localize(), style: .done, target: self, action: #selector(pickerViewValueDone))
        let items: [UIBarButtonItem] = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        textField.inputAccessoryView = doneToolbar
    }
    
    @objc private func pickerViewValueDone() {
        
        categoryTextField.resignFirstResponder()
        
        didFilterState?(states[selectedRow])
    }
    
    
    
}

extension CardCompensationHistoryHeaderView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        didFilterState?(states[selectedRow])
    }
}
