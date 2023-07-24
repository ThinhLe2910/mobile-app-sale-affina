//
//  InsuranceHealthView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 09/08/2022.
//

import UIKit

protocol InsuranceHealthViewDelegate {
    func searchCompanyProvider(name: String)
    func updateGenderModel(gender: Int)
    func updateDobModel(dob: Double)
    func updateRangeModel(from: Int, to: Int)
    func updateProviderModel(list: [CompanyProvider])
    func updateReferalModel(referal: String)
    func enableNextButton()
    func disableNextButton()
    func selectTextField(index: Int, textField: TextFieldAnimBase)
}

class InsuranceHealthView: BaseView {
    static let nib = "InsuranceHealthView"
    
    @IBOutlet weak var containerView: BaseView!
    
    @IBOutlet weak var maleButton: BaseButton!
    @IBOutlet weak var femaleButton: BaseButton!
    
    @IBOutlet weak var dobTextField: TitleTextFieldBase!
    private var datePickerView: UIDatePicker!
    @IBOutlet weak var rangeTextField: TitleTextFieldBase!
    @IBOutlet weak var companyTextField: TitleTextFieldBase!
    @IBOutlet weak var referalTextField: TitleTextFieldBase!
    
    @IBOutlet weak var rangeSlider: RangeSlider!
    
    @IBOutlet weak var emptyLabel: BaseLabel!
    @IBOutlet weak var referalTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var companyTableView: ContentSizedTableView!
    
    var delegate: InsuranceHealthViewDelegate?
    
    private var textField: TextFieldAnimBase!
    private var textFieldIndex = -1
    private var isMale = true
    private var maxRangeAmount: Int = 0
    private var lowerRangeAmount: Int = 0
    private let MAX_MONEY: CGFloat = 20000000
    
    var companyProviders: [CompanyProvider] = [] {
        didSet {
            selectedProviders = []
            companyTableView.contentSize.height = 300
            emptyLabel.isHidden = !companyProviders.isEmpty
            companyTableView.isHidden = companyProviders.isEmpty
            referalTopConstraint.constant = companyProviders.isEmpty ? 40 : 20
            
            companyTableView.reloadData()
            
            delegate?.updateProviderModel(list: selectedProviders)
        }
    }
    
    var selectedProviders: [CompanyProvider] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(InsuranceHealthView.nib, owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = .clear
        
        containerView.addTapGestureRecognizer {
            self.endEditing(true)
        }
        
        emptyLabel.isHidden = true
        referalTopConstraint.constant = 20
        
        //        rangeSlider.frame = .init(origin: rangeSlider.frame.origin, size: .init(width: bounds.width, height: rangeSlider.bounds.height))
        rangeSlider.hide()
        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged), for: .valueChanged)
        rangeTextField.textField.disable()
        
        setupDatePicker()
        
        companyTextField.textField.returnKeyType = .search
        companyTextField.rightView.addTapGestureRecognizer {
            self.searchCompanyProvider()
            self.companyTextField.textField.resignFirstResponder()
        }
        
        dobTextField.textField.delegate = self
        companyTextField.textField.delegate = self
        rangeTextField.textField.delegate = self
        referalTextField.textField.delegate = self
        
        referalTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        maleButton.addTarget(self, action: #selector(didTapGenderButton(_:)), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(didTapGenderButton(_:)), for: .touchUpInside)
        
        companyTableView.delegate = self
        companyTableView.dataSource = self
        companyTableView.register(UINib(nibName: InsuranceChooseCompanyTableViewCell.nib, bundle: nil), forCellReuseIdentifier: InsuranceChooseCompanyTableViewCell.cellId)
        setNeedsLayout()
        
        rangeSliderValueChanged()
        
        // REMOVE: 
//        datePickerView.date = Date(year: 1999, month: 06, day: 10)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @objc private func rangeSliderValueChanged() { //rangeSlider: RangeSlider
//        Logger.Logs(message: "Range slider value changed: \((rangeSlider.lowerValue).addComma()) \(rangeSlider.upperValue)")
        lowerRangeAmount = Int(MAX_MONEY * rangeSlider.lowerValue)
        maxRangeAmount = Int(MAX_MONEY * rangeSlider.upperValue)
        rangeTextField.textField.text = "\(lowerRangeAmount.addComma()) \("-") \(maxRangeAmount.addComma()) vnd"
        rangeTextField.textField.disable()
        delegate?.updateRangeModel(from: lowerRangeAmount, to: maxRangeAmount)
    }
    
    private func setupDatePicker() {
        dobTextField.rightIconView.tintColor = .appColor(.whiteMain)
        datePickerView = UIDatePicker()
        datePickerView.locale = NSLocale(localeIdentifier: "vi_VN") as Locale
        datePickerView.backgroundColor = UIColor.appColor(.whiteMain)
        datePickerView.maximumDate = Date()
        datePickerView.date = Date()
        datePickerView.datePickerMode = .date
        
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        dobTextField.rightView.addTapGestureRecognizer {
            self.dobTextField.textField.becomeFirstResponder()
        }
        
        dobTextField.textField.inputView = datePickerView
        let doneToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "DONE".localize(), style: .done, target: self, action: #selector(datePickerValueDone))
        let items: [UIBarButtonItem] = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        dobTextField.textField.inputAccessoryView = doneToolbar
    }
    
    @objc private func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "vi_VN")
        
        dobTextField.textField.text = dateFormatter.string(from: datePickerView.date)
        delegate?.updateDobModel(dob: datePickerView.date.timeIntervalSince1970 * 1000)
    }
    
    @objc private func datePickerValueDone() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "vi_VN")
        
        dobTextField.textField.text = dateFormatter.string(from: datePickerView.date)
        delegate?.updateDobModel(dob: datePickerView.date.timeIntervalSince1970 * 1000)
        dobTextField.textField.resignFirstResponder()
    }
    
    @objc private func didTapGenderButton(_ sender: UIButton) {
        if sender == maleButton {
            isMale = true
        }
        else {
            isMale = false
        }
        
        let blueColor = UIColor.appColor(.blueMain)
        let blueTextColor = UIColor.appColor(.blue)
        let whiteColor = UIColor.appColor(.whiteMain)
        maleButton.backgroundColor = isMale ? blueColor : whiteColor
        femaleButton.backgroundColor = !isMale ? blueColor : whiteColor
        maleButton.setTitleColor(isMale ? whiteColor : blueTextColor, for: .normal)
        femaleButton.setTitleColor(isMale ? blueTextColor : whiteColor, for: .normal)
        
        delegate?.updateGenderModel(gender: isMale ? 1 : 0)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
            case referalTextField.textField:
                delegate?.updateReferalModel(referal: textField.text ?? "")
                break
            default: break
        }
    }
    func searchCompanyProvider() {
        delegate?.searchCompanyProvider(name: companyTextField.textField.text ?? "")
    }
    
    func showEmptyLabel() {
        emptyLabel.isHidden = false
        companyTableView.isHidden = true
        referalTopConstraint.constant = 40
    }
    
    func hideEmptyLabel() {
        emptyLabel.isHidden = true
        companyTableView.isHidden = false
        referalTopConstraint.constant = 20
    }
    
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension InsuranceHealthView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companyProviders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InsuranceChooseCompanyTableViewCell.cellId, for: indexPath) as? InsuranceChooseCompanyTableViewCell else { return UITableViewCell() }
        if indexPath.row == companyProviders.count - 1 {
            cell.separator.isHidden = true
        }
        else {
            cell.separator.isHidden = false
        }
        cell.item = companyProviders[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    
}

// MARK: InsuranceChooseCompanyDelegate
extension InsuranceHealthView: InsuranceChooseCompanyDelegate {
    func didTapCell(item: CompanyProvider, selected: Bool) {
        var existed = false
        for (index, provider) in selectedProviders.enumerated() {
            if item.id == provider.id {
                existed = true
                selectedProviders.remove(at: index)
            }
        }
        if !existed {
            selectedProviders.append(item)
        }
        delegate?.updateProviderModel(list: selectedProviders)
    }
}

// MARK: UITextFieldDelegate
extension InsuranceHealthView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case dobTextField.textField:
            textFieldIndex = 0
            self.textField = dobTextField.textField
            break
        case rangeTextField.textField:
            textFieldIndex = 1
            self.textField = rangeTextField.textField
            break
        case companyTextField.textField:
            textFieldIndex = 2
            self.textField = companyTextField.textField
            break
        case referalTextField.textField:
            textFieldIndex = 3
            self.textField = referalTextField.textField
            break
        default:
            break
        }
        
        delegate?.selectTextField(index: textFieldIndex, textField: self.textField)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == companyTextField.textField {
            textField.resignFirstResponder()
            searchCompanyProvider()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let dobCount = dobTextField.textField.text?.count else { return }
        if dobCount > 0 {
            delegate?.enableNextButton()
        }
        else {
            delegate?.disableNextButton()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let dobCount = dobTextField.textField.text?.count else { return false }
        //        var count = string == "" ? -1 : 1
        if dobCount > 0 {
            delegate?.enableNextButton()
        }
        else {
            delegate?.disableNextButton()
        }
        
        return true
    }
    
}
