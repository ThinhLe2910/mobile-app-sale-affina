//
//  CardHospitalDetailViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 29/07/2022.
//

import UIKit

class CardHospitalDetailViewController: BaseViewController {
    
    static let nib = "CardHospitalDetailViewController"

    class func instanceFromNib() -> CardHospitalDetailViewController {
        return UINib(nibName: self.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CardHospitalDetailViewController
    }
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var hospitalNameLabel: BaseLabel!
    @IBOutlet weak var hospitalTypeLabel: BaseButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var hotlineButton: BaseButton!
    @IBOutlet weak var directionButton: BaseButton!
    @IBOutlet weak var calendarButton: BaseButton!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    private let details = ["ADDRESS".localize(), "PHONE".localize(), "WORKING_TIME".localize(), "SPECIALITIES".localize()]
    
    var item: HospitalModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideHeaderBase()
        containerBaseView.hide()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: CardHospitalDetailTableViewCell.nib, bundle: nil), forCellReuseIdentifier: CardHospitalDetailTableViewCell.cellId)
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        hotlineButton.addTarget(self, action: #selector(didTapHotlineButton), for: .touchUpInside)
        directionButton.addTarget(self, action: #selector(didTapDirectionButton), for: .touchUpInside)
        calendarButton.addTarget(self, action: #selector(didTapCalendarButton), for: .touchUpInside)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = stackView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.addSubview(blurEffectView)
        stackView.sendSubviewToBack(blurEffectView)
        
        hotlineButton.dropShadow(color: UIColor.appColor(.shadow) ?? UIColor(hex: "010953"), opacity: 0.12, offset: .init(width: 0, height: 8), radius: 16, scale: true)
        directionButton.dropShadow(color: UIColor.appColor(.shadow) ?? UIColor(hex: "010953"), opacity: 0.12, offset: .init(width: 0, height: 8), radius: 16, scale: true)
        calendarButton.dropShadow(color: UIColor.appColor(.shadow) ?? UIColor(hex: "010953"), opacity: 0.12, offset: .init(width: 0, height: 8), radius: 16, scale: true)
        
        guard let item = item else {
            return
        }
        hospitalNameLabel.text = item.name
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapHotlineButton() {
        if let phone = item?.phone?.replace(string: " ", replacement: ""), let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            print(phone)
        }
    }
    
    @objc private func didTapDirectionButton() {
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            UIApplication.shared.open(URL(string:
            "comgooglemaps://zoom=14&views=traffic")!, options: [:], completionHandler: nil)
        } else {
            print("Can't use comgooglemaps://");
        }
    }
    
    @objc private func didTapCalendarButton() {
        
    }
}


extension CardHospitalDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardHospitalDetailTableViewCell.cellId, for: indexPath) as? CardHospitalDetailTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = details[indexPath.row]
        var detail = ""
        var attributedDetail: NSAttributedString?
        switch indexPath.row {
        case 0:
                detail = item?.address ?? "\n"
        case 1:
                detail = item?.phone ??  "\n" // 012-345-6789"
        case 2:
                attributedDetail = item?.timeserving?.htmlToAttributedString
                if attributedDetail == nil { detail = " " }
        case 3:
                detail = item?.specializing ?? "\n" // "Đa khoa"
        default:
            detail = ""
        }
        if detail.isEmpty || detail == "\n" && attributedDetail != nil {
            cell.detailLabel.attributedText = attributedDetail
        } else {
            cell.detailLabel.text = detail
        }
        return cell
    }
    
}
