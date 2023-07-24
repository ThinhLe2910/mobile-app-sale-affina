//
//  ContractPersonalInforPopup.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 25/08/2022.
//

import UIKit

class ContractPersonalInforPopup: BaseView {
    @IBOutlet weak var indentityCardLabel: UILabel!
    static let nib = "ContractPersonalInforPopup"
    class func instanceFromNib() -> ContractPersonalInforPopup {
        return UINib(nibName: self.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ContractPersonalInforPopup
    }
    
    @IBOutlet weak var containerView: BaseView!
    
    @IBOutlet weak var genderLabel: BaseLabel!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var cccdLabel: BaseLabel!
    @IBOutlet weak var dobLabel: BaseLabel!
    @IBOutlet weak var closeButton: BaseButton!
    @IBOutlet weak var relationButton: BaseButton!
    
    @IBOutlet weak var buttonView: UIStackView!
    
    @IBOutlet weak var infoTableView: ContentSizedTableView!
    
    private let titles: [String] = ["PHONE".localize(), "Email", "ADDRESS".localize()]
    private var infos: [String] = []
    
    var editCallBack: (()->Void)?
    var callBack: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(ContractPersonalInforPopup.nib, owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        genderLabel.text = "GENDER".localize()
//        containerView.backgroundColor = .appColor(.whiteMain)
        indentityCardLabel.text =  "IDENTITY_CARD".localize()
        //        infoTableView.delegate = self
        infoTableView.dataSource = self
        infoTableView.register(UINib(nibName: PersonInfoTableViewCell.nib, bundle: nil), forCellReuseIdentifier: PersonInfoTableViewCell.cellId)
        
        closeButton.addTapGestureRecognizer {
            self.callBack?()
        }
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        infoTableView.dataSource = self
//        infoTableView.register(UINib(nibName: InfoTableViewCell.nib, bundle: nil), forCellReuseIdentifier: InfoTableViewCell.cellId)
//        
//        closeButton.addTapGestureRecognizer {
//            self.callBack?()
//        }
//    }
    
    func setInfo(name: String, gender: Int, cccd: String, dob: Double, email: String, phone: String, address: String, relationship: Int) {
        dobLabel.text = "\(dob/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
        
        cccdLabel.text = ""
        for i in 0..<cccd.count {
            cccdLabel.text = (cccdLabel.text ?? "") + String(cccd[i])
            if (i+1) < 12 && (i+1) % 3 == 0 {
                cccdLabel.text = (cccdLabel.text ?? "") + " "
            }
        }
        
        var phoneNumber = ""
        for i in 0..<phone.count {
            phoneNumber = phoneNumber + String(phone[i])
            if i == 2 || i == 5 {
                phoneNumber = phoneNumber + " "
            }
        }
        let address = address.split(separator: ",").joined(separator: ", ")
        infos.append(contentsOf: [phoneNumber, email, address])
        genderLabel.text = EnumGender(rawValue: gender)?.title
        
//        let normalText = ". \(name)"
//        let boldText = "\(gender == 0 ? "MISS".localize() : "MR".localize())"
//        let attrs = [NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16)] as [NSAttributedString.Key : Any]
//        let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
//        let normalString = NSMutableAttributedString(string: normalText)
//        attributedString.append(normalString)
//        nameLabel.attributedText = attributedString
        nameLabel.text = name
        
        relationButton.setTitle(ContractObjectPeopleRelationshipEnum(rawValue: relationship)?.value ?? "Bản thân", for: .normal)
    }

}

extension ContractPersonalInforPopup: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PersonInfoTableViewCell.cellId, for: indexPath) as? PersonInfoTableViewCell else { return UITableViewCell() }
        cell.titleLabel.text = titles[indexPath.row]
        if !infos.isEmpty {
            cell.infoLabel.text = infos[indexPath.row]
        }
        if indexPath.row == titles.count - 1 {
            cell.separator.hide()
        }
        else {
            cell.separator.show()
        }
        if indexPath.row == 0 {
            cell.iconImage.image = UIImage(named: "ic_phone")
            cell.iconImage.tintColor = .black
            cell.iconImage.show()
        }
        else if indexPath.row == 1 {
            cell.iconImage.image = UIImage(named: "ic_email")
            cell.iconImage.show()
        }
        else {
            cell.iconImage.hide(isImmediate: true)
        }
        return cell
    }
}
