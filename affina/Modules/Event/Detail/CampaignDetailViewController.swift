//
//  CampaignDetailViewController.swift
//  affina
//
//  Created by Intelin MacHD on 03/04/2023.
//

import UIKit

class CampaignDetailViewController: BaseViewController {
    
    //MARK: Views
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var voucherButton: UIButton!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var voucherListView: UITableView!
    
    //MARK: Contraints
    @IBOutlet weak var voucherListHeightConstraints: NSLayoutConstraint!
    @IBOutlet var contentBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableBottomConstraint: NSLayoutConstraint!
    
    //MARK: UI Variables
    private var selectedTab = 0 {
        didSet {
            if selectedTab == 0 {
                infoButton.backgroundColor = .appColor(.blueMain)
                infoButton.setTitleColor(.white, for: .normal)
                voucherButton.backgroundColor = .appColor(.whiteMain)
                voucherButton.setTitleColor(.appColor(.subText), for: .normal)
                detailLabel.isHidden = false
                voucherListView.isHidden = true
                voucherListHeightConstraints.constant = 0
                contentBottomConstraint.isActive = true
                tableBottomConstraint.isActive = false
            } else {
                infoButton.backgroundColor = .appColor(.whiteMain)
                infoButton.setTitleColor(.appColor(.subText), for: .normal)
                voucherButton.backgroundColor = .appColor(.blue)
                voucherButton.setTitleColor(.white, for: .normal)
                detailLabel.isHidden = true
                voucherListView.isHidden = false
                voucherListHeightConstraints.constant = self.voucherListView.contentSize.height
                contentBottomConstraint.isActive = false
                tableBottomConstraint.isActive = true
            }
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: Properties
    private var data: EventModel?
    private var voucherData: [EventVoucherModel] = []
    private let presenter = EventPresenter()
    private var selectedVoucher = -1
    var id: String = ""
    var callback: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTableView()
        presenter.setDelegate(input: self)
        presenter.requestGetEventDetail(id: id)
    }
    
    /**
    * Method name: mapData
    * Description: Map fetched data to view. Should be run have presenter fetched data from server
    * Parameters: None
    */
    func mapData() {
        guard let data = data else {return}
        titleLabel.attributedText = (data.shortDesc ?? "").htmlToAttributedString
        detailLabel.attributedText = (data.description ?? "").htmlToAttributedString
        detailLabel.text = "What is Lorem Ipsum?\nLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\nWhy do we use it?\nIt is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like)."
        timeLabel.text = Date(timeIntervalSince1970: Double(data.createdAt ?? 0) / 1000).convertToString(with: "HH:mm - dd/MM/YYYY")
        self.unlockScreen()
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
                    } catch(let e) {
                        Logger.Logs(message: e.localizedDescription)
                    }
                }
            }
        }
        
        voucherData = data.listVoucher ?? []
        voucherListView.reloadData()
        view.layoutIfNeeded()
    }
    
    override func initBaseView() {}
    
    override func initViews() {
        mainScrollView.contentInsetAdjustmentBehavior = .never
        backButton.roundCorners([.allCorners], radius: 20.height)
        voucherButton.titleLabel?.font = UIConstants.Fonts.appFont(.Bold, 14.height)
        infoButton.titleLabel?.font = UIConstants.Fonts.appFont(.Bold, 14.height)
        voucherButton.layer.cornerRadius = 16
        infoButton.layer.cornerRadius = 16
        selectedTab = 0
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGoBack)))
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if selectedTab == 1 {
            voucherListHeightConstraints.constant = self.voucherListView.contentSize.height
        }
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        selectedTab = 0
    }
    
    @IBAction func voucherButtonTapped(_ sender: Any) {
        selectedTab = 1
    }
    
    @objc func handleGoBack() {
        callback?()
        navigationController?.popViewController(animated: true)
    }
}

//MARK: Presenter delgate handler
extension CampaignDetailViewController: EventDetailProtocol {
    func handleGetVoucherSummarySuccess(summary: VoucherSummaryModel) {
        AppStateManager.shared.userCoin = summary.coin ?? 0
        if selectedVoucher > -1 && selectedVoucher < voucherData.count {
            let vc = VoucherDetailViewController()
            vc.voucherId = voucherData[selectedVoucher].voucherId ?? ""
            vc.providerId = ""
            vc.voucherDetailType = .notMine
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func showError(error: ApiError) {
        showErrorPopup(error: error)
    }
    
    func updateInfo(data: EventModel) {
        self.data = data
        mapData()
    }
}

extension CampaignDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        voucherListView.dataSource = self
        voucherListView.delegate = self
        voucherListView.register(UINib(nibName: VoucherCampaignTableViewCell.nib, bundle: nil), forCellReuseIdentifier: VoucherCampaignTableViewCell.description())
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        voucherData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: VoucherCampaignTableViewCell.description()) as? VoucherCampaignTableViewCell {
            cell.data = voucherData[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row < voucherData.count) {
            selectedVoucher = indexPath.row
            presenter.getVoucherSummary()
        }
    }
}
