//
//  VoucherDetailViewController.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit
import SkeletonView

enum VoucherDetailType: Int {
    case mine
    case notMine
    case company
}

class VoucherDetailViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var backButton: BaseButton!
    
    @IBOutlet weak var bottomView: BaseView!
    
    @IBOutlet weak var buyButton: BaseButton!
    @IBOutlet weak var reviewButton: BaseButton!
    @IBOutlet weak var markUsedButton: BaseButton!
    
    @IBOutlet weak var addButton: BaseButton!
    @IBOutlet weak var minusButton: BaseButton!
    
    @IBOutlet weak var emptyReviewLabel: BaseLabel!
    @IBOutlet weak var reviewTableView: ContentSizedTableView!
    
    @IBOutlet weak var quantityLabel: BaseLabel!
    @IBOutlet weak var pointLabel: BaseLabel!
    @IBOutlet weak var oldPointLabel: BaseLabel!
    
    @IBOutlet weak var voucherImageView: UIImageView!
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var dateLabel: BaseLabel!
    
    @IBOutlet weak var qrImageView: UIImageView!
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var contentLabel: BaseLabel!
    @IBOutlet weak var ratedStarsView: RatedStarsView!
    
    @IBOutlet weak var ratedCountLabel: BaseLabel!
    
    
    @IBOutlet weak var buyButtonView: BaseView!
    @IBOutlet weak var reviewButtonView: UIStackView!
    @IBOutlet weak var quantityView: BaseView!
    @IBOutlet weak var markUsedView: BaseView!
    
    @IBOutlet weak var qrHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var qrBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardSerialLabel: UILabel!
    @IBOutlet weak var copyLabel: UILabel!
    @IBOutlet weak var qrViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardSerialHeightConstraint: NSLayoutConstraint!
    
    private let presenter = VoucherDetailViewPresenter()
    
    var viewType: FlexiCategoryViewType = .voucher
    var voucherDetailType: VoucherDetailType = .notMine
    var voucherId: String = ""
    var providerId: String = ""
    var code: String = ""
    
    private var detailModel: VoucherDetailModel?
    private var myDetailModel: MyVoucherModel?
    private var ratingList: [VoucherRatingModel] = []
    
    private let MIN_QUANTITY = 1
    private let MAX_QUANTITY = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ratedCountLabel.text = "(0) " + "RATE".localize().capitalized
        setupHeaderView()
        containerBaseView.hide()
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        reviewTableView.register(UINib(nibName: ReviewTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ReviewTableViewCell.identifier)
        
        ratedStarsView.ratedStar = 0
        ratedStarsView.starType = 1
        
        addBlurEffect(bottomView)
        
        minusButton.disable()
        
        //        buyButtonView.hide()
        //        quantityView.hide()
        if self.voucherDetailType == .mine {
            quantityView.hide(isImmediate: true)
            self.markUsedView.show()
            self.reviewButtonView.hide(isImmediate: true)
            self.buyButtonView.hide(isImmediate: true)
        }
        else {
            quantityView.show()
            self.markUsedView.hide(isImmediate: true)
            self.reviewButtonView.hide(isImmediate: true)
            self.buyButtonView.show()
            self.buyButton.localizeTitle = UIConstants.isLoggedIn ? "REDEEM_VOUCHER".localize().capitalized : "LOGIN_TO_BUY".localize().capitalized
        }
        
        emptyReviewLabel.hide()
        
        qrBottomConstraint.constant = 0 // 16
        qrHeightConstraint.constant = 0 // 160
        qrViewHeightConstraint.constant = 0
        
        buyButton.localizeTitle = UIConstants.isLoggedIn ? "REDEEM_VOUCHER".localize().capitalized : "LOGIN_TO_BUY".localize().capitalized
        
        backButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        buyButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        reviewButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        markUsedButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
        cardNumberLabel.font = UIConstants.Fonts.appFont(.Bold, 16.height)
        cardSerialLabel.font = UIConstants.Fonts.appFont(.Bold, 16.height)
        copyLabel.font = UIConstants.Fonts.appFont(.Bold, 14.height)
        copyLabel.text = "COPY".localize().uppercased()
        copyLabel.textColor = UIColor.appColor(.greenMain)
        copyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyTextTouched)))
        copyLabel.isUserInteractionEnabled = true
        
        presenter.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewType == .company {
            if UIConstants.isLoggedIn && (AppStateManager.shared.flexiSummary == nil || AppStateManager.shared.flexiSummary!.point == 0) {
                presenter.getSMESummary()
            }
        } else {
            if UIConstants.isLoggedIn && AppStateManager.shared.userCoin == 0 {
                presenter.getVoucherSummary()
            }
        }
        
        if voucherDetailType == .mine {
            presenter.getMyVoucherDetail(voucherId: voucherId, code: code, providerId: providerId)
        } else if voucherDetailType == .company {
            presenter.getSMEMyVoucherDetail(voucherId: voucherId, code: code, providerId: providerId)
        } else {
            presenter.getDetail(voucherId: voucherId, providerId: providerId)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        buyButton.localizeTitle = UIConstants.isLoggedIn ? "REDEEM_VOUCHER".localize().capitalized : "LOGIN_TO_BUY".localize().capitalized
        
    }
    
    private func setupHeaderView() {
        addBlurStatusBar()
        headerBaseView.hide()
    }
    
    @objc private func didTapButton(_ button: BaseButton) {
        switch button {
        case backButton:
            didClickLeftBaseButton()
        case buyButton:
            if UIConstants.isLoggedIn {
                if let quantity = Int(quantityLabel.text ?? "0"),
                   quantity >= MIN_QUANTITY,
                   quantity <= MAX_QUANTITY,
                   !voucherId.isEmpty {
                    if viewType == .voucher {
                        presenter.buyVoucher(voucherId: voucherId, quantity: quantity, providerId: providerId)
                    }
                    else {
                        presenter.buySMEVoucher(voucherId: voucherId, quantity: quantity, providerId: providerId)
                    }
                }
            }
            else {
                let vc = WelcomeViewController()
                presentInFullScreen(UINavigationController(rootViewController: vc), animated: true)
            }
        case addButton:
            let quantity = (Int(quantityLabel.text ?? "0") ?? 0) + 1
            quantityLabel.text = "\(quantity)"
            minusButton.enable()
            if quantity >= MAX_QUANTITY {
                addButton.disable()
                return
            }
            break
        case minusButton:
            let quantity = (Int(quantityLabel.text ?? "1") ?? 1) - 1
            quantityLabel.text = "\(quantity)"
            addButton.enable()
            if quantity <= MIN_QUANTITY {
                minusButton.disable()
                return
            }
            break
        case reviewButton:
            if isRatedVoucher() { return }
            let vc = VoucherReviewViewController()
            vc.providerId = myDetailModel?.providerID ?? ""
            vc.code = myDetailModel?.code ?? ""
            vc.voucherId = myDetailModel?.voucherID ?? ""
            navigationController?.pushViewController(vc, animated: true)
            
        case markUsedButton:
            guard let model = myDetailModel else { return }
            presenter.markUsed(voucherId: model.voucherID ?? "", code: model.code ?? "")
        default:
            break
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setDefaults()
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let colorParameters = [
                    "inputColor0": CIColor(color: UIColor.black), // Foreground
                    "inputColor1": CIColor(color: UIColor.clear) // Background
                ]
                let colored = output.applyingFilter("CIFalseColor", parameters: colorParameters)
                
                return UIImage(ciImage: colored)
            }
        }
        
        return nil
    }
    
    
    
    private func updateBuyButton() {
        if viewType == .company {
            let coin = Int(AppStateManager.shared.flexiSummary?.point ?? 0)
            if UIConstants.isLoggedIn && ( coin == 0 || coin < (detailModel?.price ?? 0)) {
                buyButton.disable()
            }
            else {
                buyButton.enable()
            }
            return
        }
        let coin = Int(AppStateManager.shared.userCoin)
        if UIConstants.isLoggedIn && ( coin == 0 || coin < (detailModel?.price ?? 0)) {
            buyButton.disable()
        }
        else {
            buyButton.enable()
        }
    }
    
    func shouldShowBottom() -> Bool {
        if isExpiredVoucher() {
            return false
        }
        
        if isRatedVoucher() {
            if isUsedVoucher() {
                return false
            }
            return true
        }
        
        return true
    }
    
    func shouldShowMarkAsRead() -> Bool{
        if !isUsedVoucher() {
            if myDetailModel?.providerID != nil {
                return true
            }
        }
        return false
    }
    
    func shouldShowRate() -> Bool {
        return isUsedVoucher()
    }
    
    // MARK: updateMyDetailUI
    func updateMyDetailUI() {
        guard let detailModel = myDetailModel else { return }
        
        titleLabel.text = detailModel.voucherName
        
        let expiredDate: String = "\((detailModel.expiredAt ?? 0) / 1000)".timestampToFormatedDate(format: "dd.MM.yyyy")
        dateLabel.text = "\("EXPIRE_DATE".localize().capitalized): " + expiredDate
        summaryLabel.attributedText = detailModel.summary?.htmlToAttributedString
        contentLabel.attributedText = detailModel.content?.htmlToAttributedString
        
        ratedCountLabel.text = "(\(detailModel.ratingList?.count ?? 0)) \("RATE".localize())"
        bottomView.isHidden = !shouldShowBottom()
        reviewButtonView.isHidden = !shouldShowRate()
        markUsedView.isHidden = !shouldShowMarkAsRead()
        //        if shouldShowBottom() {
        //
        //            if !isUsedVoucher() {
        //                if detailModel.providerID != nil {
        //                    quantityView.hide(isImmediate: true)
        //                    buyButtonView.hide(isImmediate: true)
        //                    reviewButtonView.hide(isImmediate: true)
        //
        //                    markUsedView.show()
        //                } else {
        //                    quantityView.hide(isImmediate: true)
        //                    buyButtonView.hide(isImmediate: true)
        //                    reviewButtonView.hide(isImmediate: true)
        //
        //                    markUsedView.show()
        //                }
        //
        //            } else {
        //                quantityView.hide(isImmediate: true)
        //                buyButtonView.hide(isImmediate: true)
        //                reviewButtonView.hide(isImmediate: true)
        //
        //                markUsedView.hide()
        //            }
        //
        //        }
        
        //        if !isUsedVoucher() {
        //            bottomView.show()
        //            quantityView.hide(isImmediate: true)
        //            markUsedView.show()
        //            buyButtonView.hide(isImmediate: true)
        //            reviewButtonView.hide(isImmediate: true)
        //        }
        //        else if isUsedVoucher() && !isRatedVoucher() {
        //            reviewButtonView.show()
        //            quantityView.hide(isImmediate: true)
        //            markUsedView.hide(isImmediate: true)
        //            buyButtonView.hide(isImmediate: true)
        //        }
        //        else if isExpiredVoucher() || isRatedVoucher() {
        //            bottomView.hide(isImmediate: true)
        //            quantityView.hide(isImmediate: true)
        //            markUsedView.hide(isImmediate: true)
        //            buyButtonView.hide(isImmediate: true)
        //
        //            if isRatedVoucher() {
        //                reviewButtonView.hide(isImmediate: true)
        //            }
        //        }
        //
        //        if (isExpiredVoucher() && isRatedVoucher()) {
        //            bottomView.hide()
        //        }
        //
        //        if !(isExpiredVoucher() || isRatedVoucher()) {
        //            if detailModel.providerID == nil || (detailModel.providerID?.isEmpty ?? true) {
        //                markUsedView.hide(isImmediate: true)
        //                bottomView.hide(isImmediate: true)
        //            }
        //
        //            if (detailModel.providerID == nil || (detailModel.providerID?.isEmpty ?? true)) && isUsedVoucher() {
        //                markUsedView.hide(isImmediate: true)
        //                reviewButtonView.show()
        //                bottomView.show()
        //            }
        //        }
        
        let ratings: CGFloat = CGFloat((detailModel.totalRatingPoint ?? 0)/(detailModel.totalRating ?? 1))
        ratedStarsView.ratedStar = ratings
        var url : URL?
        if let code = detailModel.code {
            cardNumberLabel.text = code
        } else {
            cardNumberLabel.text = ""
        }
        
        if let serial = detailModel.serial {
            cardSerialLabel.text = serial
            cardSerialHeightConstraint.constant = 21
        } else {
            cardSerialLabel.text = ""
            cardSerialHeightConstraint.constant = 0
        }
        if let image = detailModel.imageCode{
            guard let url = URL(string: detailModel.imageCode!) else{
                qrImageView.isHidden = true
                return
            }
            qrBottomConstraint.constant = 16
            qrHeightConstraint.constant = 160
            qrViewHeightConstraint.constant = 230
            qrImageView.isSkeletonable = true
            DispatchQueue.main.async {
                self.qrImageView.showSkeleton()
            }
            CacheManager.shared.imageFor(url: url) { [weak self] image, error in
                DispatchQueue.main.async {
                    self?.qrImageView.hideSkeleton()
                }
                if error != nil {
                    DispatchQueue.main.async {
                        self?.qrImageView.image = UIImage(named: "placeholder")
                    }
                    Logger.Logs(event: .error, message: error?.localizedDescription ?? "Cache Image Error")
                    return
                }
                DispatchQueue.main.async {
                    self?.qrImageView.image = image
                }
            }
        }
        
        
        
        voucherImageView.isSkeletonable = true
        DispatchQueue.main.async {
            self.voucherImageView.showSkeleton()
        }
        guard let imageString = detailModel.voucherImage, !imageString.isEmpty else { return }
        if(!imageString.starts(with: "http")){
            guard let jsonObject = try? JSONDecoder().decode([String: String].self, from: imageString.data(using: .utf16) ?? Data()) else {return}
            url = URL(string: API.STATIC_RESOURCE + (jsonObject["imageLong_1"] ?? ""))
        }else{
            url = URL(string: imageString)
        }
        guard let url = url else{return}
        CacheManager.shared.imageFor(url: url) { [weak self] image, error in
            DispatchQueue.main.async {
                self?.voucherImageView.hideSkeleton()
            }
            if error != nil {
                DispatchQueue.main.async {
                    self?.voucherImageView.image = UIImage(named: "placeholder")
                }
                Logger.Logs(event: .error, message: error?.localizedDescription ?? "Cache Image Error")
                return
            }
            DispatchQueue.main.async {
                self?.voucherImageView.image = image
            }
        }
        voucherImageView.contentMode = .scaleAspectFill
        
    }
    
    // MARK: updateDetailUI
    func updateDetailUI() {
        print("updateDetailUI")
        guard let detailModel = detailModel else { return }
        bottomView.show()
        titleLabel.text = detailModel.voucherName
        
        let expiredDate: String = detailModel.expireDate != nil ? "\((detailModel.expireDate ?? 0) / 1000)".timestampToFormatedDate(format: "dd.MM.yyyy") : (detailModel.expireInfo ?? "")
        dateLabel.text = "\("EXPIRE_DATE".localize()): " + expiredDate
        
        contentLabel.attributedText = detailModel.content?.htmlToAttributedString
        
        ratedCountLabel.text = "(\(detailModel.ratingList?.count ?? 0)) \("RATE".localize())"
        
        updateBuyButton()
        if UIConstants.isLoggedIn {
            if viewType == .company {
                if isExpiredVoucher() || (Double(AppStateManager.shared.flexiSummary?.point ?? -1) < Double(detailModel.price ?? 0)){
                    buyButton.disable()
                }
            } else {
                if isExpiredVoucher() || (AppStateManager.shared.userCoin < Double(detailModel.price ?? 0)){
                    buyButton.disable()
                }
            }
            
        } else {
            if isExpiredVoucher() {
                buyButton.disable()
            }
        }
        
        
        if detailModel.status == 2 {
            buyButton.disable()
        }
        
        let ratings: CGFloat = CGFloat((detailModel.totalRatingPoint ?? 0)/(detailModel.totalRating ?? 1))
        ratedStarsView.ratedStar = ratings
        print(detailModel)
        pointLabel.text = "\((detailModel.price ?? 0).addComma())" + " " + "\(viewType == .voucher ? "Xu" : "POINT")".localize().lowercased()
        voucherImageView.isSkeletonable = true
        DispatchQueue.main.async {
            self.voucherImageView.showSkeleton()
        }
        
        if providerId.isEmpty {
            var images: [String: String] = [:]
            if let data = detailModel.images?.data(using: .utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: String]
                    images = json ?? [:]
                } catch {
                    Logger.Logs(message: "Something went wrong")
                }
            }
            CacheManager.shared.imageFor(url: URL(string: API.STATIC_RESOURCE + (images["imageLong_1"] ?? ""))!) { [weak self] image, error in
                DispatchQueue.main.async {
                    self?.voucherImageView.hideSkeleton()
                }
                if error != nil {
                    DispatchQueue.main.async {
                        self?.voucherImageView.image = UIImage(named: "placeholder")
                    }
                    Logger.Logs(event: .error, message: error?.localizedDescription ?? "Cache Image Error")
                    return
                }
                DispatchQueue.main.async {
                    self?.voucherImageView.image = image
                }
            }
        }
        else {
            guard let image = detailModel.image, let url = URL(string: image) else { return }
            CacheManager.shared.imageFor(url: url) { [weak self] image, error in
                DispatchQueue.main.async {
                    self?.voucherImageView.hideSkeleton()
                }
                if error != nil {
                    DispatchQueue.main.async {
                        self?.voucherImageView.image = UIImage(named: "placeholder")
                    }
                    Logger.Logs(event: .error, message: error?.localizedDescription ?? "Cache Image Error")
                    return
                }
                DispatchQueue.main.async {
                    self?.voucherImageView.image = image
                }
            }
        }
    }
    
    @objc func copyTextTouched() {
        guard let detailModel = myDetailModel else { return }
        let code = detailModel.code ?? ""
        let serial = detailModel.serial
        let copyText = code + (serial != nil ? "\n\(serial ?? "")" : "")
        UIPasteboard.general.string = copyText
        AlertService.showToast(message: "COPY_SUCCESSFULLY".localize())
    }
    
    func updateUI() {
        if voucherDetailType == .mine {
            updateMyDetailUI()
        }
        else {
            updateDetailUI()
        }
    }
    
    func isRatedVoucher() -> Bool {
        guard let voucher = myDetailModel else { return false }
        for i in voucher.ratingList ?? [] {
            if i.userId == AppStateManager.shared.profile?.userID {
                return true
            }
        }
        return false
    }
    func isUsedVoucher() -> Bool {
        guard let myDetailModel = myDetailModel else { return true }
        if myDetailModel.isUse == 1 { return true }
        return false
    }
    
    func isExpiredVoucher() -> Bool {
        if myDetailModel != nil {
            guard let myDetailModel = myDetailModel else { return true }
            let expireDate = (myDetailModel.expiredAt ?? 0)/1000
            if Date().timeIntervalSince1970 >= expireDate { return true }
            
            return false
        } else {
            guard let myDetailModel = detailModel else { return true }
            guard let expireDate = myDetailModel.expireDate else { return false }
            if Date().timeIntervalSince1970 >= expireDate / 1000 { return true }
            return false
        }
    }
}

// MARK: UITableViewDelegate + UITableViewDatasource
extension VoucherDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.identifier, for: indexPath) as? ReviewTableViewCell else { return UITableViewCell() }
        let rating = ratingList[indexPath.row]
        cell.item = rating
        
        return cell
    }
    
    
}

// MARK: VoucherDetailViewDelegate
extension VoucherDetailViewController: VoucherDetailViewDelegate {
    func updateMyVoucherDetail(detail: MyVoucherModel) {
        myDetailModel = detail
        ratingList = detail.ratingList ?? []
        DispatchQueue.main.async {
            self.updateUI()
            self.reviewTableView.reloadData()
            self.reviewTableView.isHidden = self.ratingList.isEmpty
            self.emptyReviewLabel.isHidden = !self.ratingList.isEmpty
        }
    }
    
    func updateVoucherDetail(detail: VoucherDetailModel) {
        detailModel = detail
        detailModel?.providerId = providerId
        ratingList = detail.ratingList ?? []
        DispatchQueue.main.async {
            self.updateUI()
            self.reviewTableView.reloadData()
            self.reviewTableView.isHidden = self.ratingList.isEmpty
            self.emptyReviewLabel.isHidden = !self.ratingList.isEmpty
        }
    }
    
    func updateListReviews(list: [CommentModel]) {
        
    }
    
    func buyVoucherSuccess(coin: Double) {
        if viewType == .company {
            AppStateManager.shared.flexiSummary?.point = Int(coin)
        } else {
            AppStateManager.shared.userCoin = coin
        }
        DispatchQueue.main.async {
            self.updateBuyButton()
            
            AlertService.showToast(message: "DONE".localize())
        }
    }
    
    func handleBuyVoucherError(message: String) {
        queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: message, okTitle: "GOT_IT".localize(), cancelTitle: "") {
            self.hideBasePopup()
        } handler: {
            
        }
    }
    
    func lockUI() {
        self.lockScreen()
    }
    
    func unlockUI() {
        self.unlockScreen()
    }
    
    func showError(error: ApiError) {
        
    }
    
    func showAlert() {
        
    }
    
    func markUsedSuccess() {
        if voucherDetailType == .mine {
            presenter.getMyVoucherDetail(voucherId: voucherId, code: code, providerId: providerId)
        }
        else {
            presenter.getDetail(voucherId: voucherId, providerId: providerId)
        }
    }
    
    func handleMarkUsedError(error: ApiError) {
        
    }
    
}
