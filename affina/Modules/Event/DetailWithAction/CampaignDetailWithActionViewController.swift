//
//  CampaignDetailWithActionViewController.swift
//  affina
//
//  Created by Intelin MacHD on 04/04/2023.
//

import UIKit

class CampaignDetailWithActionViewController: BaseViewController {
    static let nib = "CampaignDetailWithActionViewController"
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var actionButton: BaseButton!
    
    private let presenter = EventPresenter()
    var id = ""
    private var data: EventBannerModel? {
        didSet {
            if data != nil {
                mapData()
            }
        }
    }
    override func initBaseView() {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setDelegate(input: self)
        self.lockScreen()
        presenter.requestGetBannerDetail(id: id)
        // Do any additional setup after loading the view.
    }
    
    func mapData() {
        guard let data = data else {return}
        titleLabel.attributedText = (data.shortDesc ?? "").htmlToAttributedString
        timeLabel.text = Date(timeIntervalSince1970: Double(data.createdAt ?? 0) / 1000).convertToString(with: "HH:mm - dd/MM/YYYY")
        contentLabel.attributedText = (data.description ?? "").htmlToAttributedString
        actionButton.setTitle(data.actionContent ?? "", for: .normal)
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            if data.images != nil {
                if data.images!.count > 0 {
                    do {
                        guard let images = data.images else { return }
                        let jsonArray = try JSONDecoder().decode([[String: String]].self, from: images.data(using: .utf16) ?? Data())
                        
                        //Banner
                        if let bannerItem = jsonArray.first(where: {$0["name"] == "image_long_one"}) {
                            let urlString = (bannerItem["link"] != nil) ? "\(API.STATIC_RESOURCE)\(bannerItem["link"] ?? "")" : ""
                            guard let url = URL(string: urlString) else { return }
                            let data = try Data(contentsOf: url)
                            DispatchQueue.main.async {
                                self.bannerImageView.image = UIImage(data: data)
                            }
                        }
                        
                        //Icon
                        if let iconItem = jsonArray.first(where: {$0["name"] == "image_one"}) {
                            let urlString = (iconItem["link"] != nil) ? "\(API.STATIC_RESOURCE)\(iconItem["link"] ?? "")" : ""
                            guard let url = URL(string: urlString) else { return }
                            let data = try Data(contentsOf: url)
                            DispatchQueue.main.async {
                                self.iconImageView.image = UIImage(data: data)
                            }
                        }
                    } catch(let e) {
                        Logger.Logs(message: e.localizedDescription)
                    }
                }
            }
            DispatchQueue.main.async {
                self.unlockScreen()
            }
        }
    }
    
    override func initViews() {
        mainScrollView.contentInsetAdjustmentBehavior = .never
        iconImageView.layer.borderColor = UIColor.white.cgColor
        iconImageView.layer.borderWidth = 4.height
        iconImageView.layer.cornerRadius = 12.height
        backButton.layer.cornerRadius = 20.height
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGoBack)))
        actionButton.backgroundColor = .appColor(.blueMain)
        actionButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        actionButton.cornerRadius = 16.height
    }
    
    @objc func handleGoBack() {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func onPressActionButton(_ sender: Any) {
        guard let data = data, let action = data.action else {return}
        switch action {
            case 0:
                let vc = VoucherPointViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                if UIConstants.isLoggedIn {
                    let vc = FlexiCategoriesViewController()
                    vc.viewType = .voucher
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    let vc = WelcomeViewController()
                    presentInFullScreen(UINavigationController(rootViewController: vc), animated: true)
                }
            case 2:
                if UIConstants.isLoggedIn {
                    let vc = VoucherListViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                } else {
                    let vc = WelcomeViewController()
                    presentInFullScreen(UINavigationController(rootViewController: vc), animated: true)
                }

            case 3:
                if UIConstants.isLoggedIn {
                    let vc = VoucherListViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                } else {
                    let vc = WelcomeViewController()
                    presentInFullScreen(UINavigationController(rootViewController: vc), animated: true)
                }

            case 4:
                if UIConstants.isLoggedIn {
                    let vc = ChangePersonalInforViewController(nibName: ChangePersonalInforViewController.nib, bundle: nil)
                    navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    let vc = WelcomeViewController()
                    presentInFullScreen(UINavigationController(rootViewController: vc), animated: true)
                }
            case 5:
                let vc = InsuranceApproachViewController()
                self.presentInFullScreen(UINavigationController(rootViewController: vc), animated: true)
            case 6:
                if UIConstants.isLoggedIn {
                    let vc = ChangePersonalInforViewController(nibName: ChangePersonalInforViewController.nib, bundle: nil)
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = WelcomeViewController()
                    presentInFullScreen(UINavigationController(rootViewController: vc), animated: true)
                }
            default:
                break
        }
    }
}

extension CampaignDetailWithActionViewController: EventBannerDetailProtocol {
    func updateInfo(data: EventBannerModel) {
        self.data = data
    }
    
    func showError(error: ApiError) {
        showErrorPopup(error: error)
    }
}
