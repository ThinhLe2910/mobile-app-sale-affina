//
//  InformationReviewView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/08/2022.
//

import UIKit

class InformationReviewView: UIView {
    static let nib = "InformationReviewView"
    class func instanceFromNib() -> InformationReviewView {
        return UINib(nibName: self.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! InformationReviewView
    }
    
    @IBOutlet weak var containerView: BaseView!

    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var cccdLabel: BaseLabel!
    @IBOutlet weak var dobLabel: BaseLabel!
    @IBOutlet weak var editButton: BaseButton!
    @IBOutlet weak var confirmButton: BaseButton!
    
    @IBOutlet weak var buttonView: UIStackView!
    
    @IBOutlet weak var infoTableView: ContentSizedTableView!
    
    private let titles: [String] = ["PHONE".localize(), "Email", "ADDRESS".localize()]
    private var infos: [String] = []
    
    var editCallBack: (()->Void)?
    var confirmCallBack: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(InformationReviewView.nib, owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = .clear
        
        containerView.addTapGestureRecognizer {
            self.buttonView.layer.opacity = 1
            self.buttonView.isUserInteractionEnabled = true
        }
        
        self.buttonView.layer.opacity = 0.5
        self.buttonView.isUserInteractionEnabled = false
    
//        infoTableView.delegate = self
        infoTableView.dataSource = self
        infoTableView.register(UINib(nibName: InfoTableViewCell.nib, bundle: nil), forCellReuseIdentifier: InfoTableViewCell.cellId)
    
        editButton.addTapGestureRecognizer {
            self.editCallBack?()
        }
        confirmButton.addTapGestureRecognizer {
            self.confirmCallBack?()
        }
        
        genderImageView.image = UIImage(named: "ic_male")
    }
    
    func setInfo(name: String, gender: Int, cccd: String, dob: Double, email: String, phone: String, address: String) {
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
        infos.append(contentsOf: [phoneNumber, email, address])
        genderImageView.image = UIImage(named: "\(gender == 0 ? "ic_female" : "ic_male")")
        
        let normalText = ". \(name)"
        let boldText = "\(gender == 0 ? "MISS".localize() : "MR".localize())"
        let attrs = [NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16)] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString.append(normalString)
        nameLabel.attributedText = attributedString
    }
}

extension InformationReviewView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.cellId, for: indexPath) as? InfoTableViewCell else { return UITableViewCell() }
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
        return cell
    }
}
