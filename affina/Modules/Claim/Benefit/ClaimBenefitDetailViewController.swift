//
//  ClaimBenefitDetailViewController.swift
//  affina
//
//  Created by Dylan on 28/09/2022.
//

import UIKit
import SwiftyJSON
import PhotosUI

class ClaimBenefitDetailViewController: BaseViewController{
    
    @IBOutlet weak var iconTypeImageView: UIImageView!
    
    @IBOutlet weak var benefitLabel: BaseLabel!
    @IBOutlet weak var claimAmountLabel: BaseLabel!
    @IBOutlet weak var dateLabel: BaseLabel!
    @IBOutlet weak var stateLabel: BaseButton!
    
    @IBOutlet weak var realClaimLabel: BaseLabel!
    @IBOutlet weak var requestAmountLabel: BaseLabel!
    @IBOutlet weak var realAmountLabel: BaseLabel!
    
    @IBOutlet weak var rejectReasonLabel: BaseLabel!
    @IBOutlet weak var approveReasonLabel: BaseLabel!
    @IBOutlet weak var reasonLabel: BaseLabel!
    
    //    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var paymentView: BaseView!
    
    @IBOutlet weak var treatmentTableView: ContentSizedTableView!
    @IBOutlet weak var paymentTableView: ContentSizedTableView!
    @IBOutlet weak var requestPayemntTableView: ContentSizedTableView!
    @IBOutlet weak var infoPaymentTableView: ContentSizedTableView!
    
    @IBOutlet weak var proofCollectionView: UICollectionView!
    
    @IBOutlet weak var requirementView: BaseView!
    @IBOutlet weak var additionReportView: BaseView!
    @IBOutlet weak var approveClaimView: BaseView!
    @IBOutlet weak var declineClaimView: BaseView!
    @IBOutlet weak var realClaimView: BaseView!
    @IBOutlet weak var infoPaymentView: BaseView!
    @IBOutlet weak var downloadContactView: BaseView!
    
    @IBOutlet weak var attachButton: BaseButton!
    @IBOutlet weak var downloadContactButton: BaseButton!
    
    @IBOutlet weak var youNeedUpdateLabel: BaseLabel!
    @IBOutlet weak var youNeedUpdateLabel2: BaseLabel!
    @IBOutlet weak var officeNameLabel: BaseLabel!
    @IBOutlet weak var addressLabel: BaseLabel!
    @IBOutlet weak var phoneNumberLabel: BaseLabel!
    
    @IBOutlet weak var approveClaimLabel: BaseLabel!
    
    @IBOutlet weak var statusLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    private let imagePicker: UIImagePickerController = UIImagePickerController()
    
    private lazy var phImagePicker: UIViewController = {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 0
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            return picker
        }
        return UIViewController()
    }()
    
    private var isHistoryView = false
    
    private let treatmentTitles: [String] = [
        "\("EXAMINATION_DATE_HOSPITAL_DATE".localize())@\("DISCHARGE_DATE".localize())",
        "TREATMENT_PLACE".localize(),
        "DIAGNOSE".localize(),
        "TOTAL_PAYABLE_VND".localize()
    ]
    
    private var treatmentDatas: [String] = []
    
    private var paymentTitles: [String] = [
        "BANK_NAME".localize(),
        "ACCOUNT_HOLDER".localize(),
        "ACCOUNT_NUMBER".localize()
    ]
    private var paymentDatas: [String] = []
    
    private var uploads: [File] = []
    
    private var linkPaperDocument: String = ""
    
    private let listFormClaim: [ListSetupFormClaim] = LayoutBuilder.shared.getListFormClaim()
    
    private var hiddenSections = Set<Int>()
    
    private var model: ClaimDetailModel?
    
    var maximumAmount: Int = 0
    var benefitName: String = ""
    var claimId: String = ""
    
    private lazy var presenter: ClaimBenefitDetailPresenter = {
        let presenter = ClaimBenefitDetailPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    private var images: [UIImage] = []
    
    private let termsHeaders: [String] = [
        "BENEFIT".localize(),
        "APPLICALE".localize(),
        "PAYMENT_METHOD".localize(),
        "INSURANCE_EXCLUSION".localize(),
        "PARTICIPATION_TERMS".localize()
    ]
    
    private var terms: [[ContractTermModel]] = [[
        ContractTermModel(title: "Sed cursus nulla eu mi lacinia:", desc: "Phasellus eleifend mauris at pellentesque placerat. Sed ac viverra eros.", subDescs: []),
        ContractTermModel(title: "Mauris mattis nulla enim:", desc: "Donec consequat felis vel leo iaculis tincidunt. Donec eget nisi eros.", subDescs: []),
        ContractTermModel(title: "Integer imperdiet turpis in dui vehicula:", desc: "Vestibulum faucibus luctus est eget volutpat. Proin eget feugiat leo. Etiam sit amet tincidunt risus, eu lobortis dui.", subDescs: ["Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", "Proin varius mollis augue, eu suscipit odio commodo sit amet.", "Sed quis volutpat mi."]),
    ], [], [], [], []]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadContactButton.isHidden = true
        containerBaseView.hide(isImmediate: true)
        //        view.backgroundColor = .appColor(.backgroundLightGray)
        view.backgroundColor = .appColor(.blueUltraLighter)
        
        setupHeaderView()
        
        showNotePopup()
        
        benefitLabel.text = benefitName
        claimAmountLabel.text = "\(maximumAmount.addComma()) vnd"
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        treatmentTableView.delegate = self
        treatmentTableView.dataSource = self
        treatmentTableView.register(UINib(nibName: InfoTableViewCell.nib, bundle: nil), forCellReuseIdentifier: InfoTableViewCell.cellId)
        treatmentTableView.register(UINib(nibName: DoubleColumnTableViewCell.nib, bundle: nil), forCellReuseIdentifier: DoubleColumnTableViewCell.cellId)
        
        paymentTableView.delegate = self
        paymentTableView.dataSource = self
        paymentTableView.register(UINib(nibName: InfoTableViewCell.nib, bundle: nil), forCellReuseIdentifier: InfoTableViewCell.cellId)
        
        proofCollectionView.delegate = self
        proofCollectionView.dataSource = self
        proofCollectionView.register(UINib(nibName: AttachedImageCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: AttachedImageCollectionViewCell.cellId)
        
        requestPayemntTableView.delegate = self
        requestPayemntTableView.dataSource = self
        requestPayemntTableView.register(UINib(nibName: InfoTableViewCell.nib, bundle: nil), forCellReuseIdentifier: InfoTableViewCell.cellId)
        
        infoPaymentTableView.delegate = self
        infoPaymentTableView.dataSource = self
        infoPaymentTableView.register(UINib(nibName: InfoTableViewCell.nib, bundle: nil), forCellReuseIdentifier: InfoTableViewCell.cellId)
        
        imagePicker.delegate = self
        
        presenter.getClaimDetail(id: claimId)
        
        statusLabelWidthConstraint.constant = (stateLabel.title(for: .normal)?.widthWithConstrainedHeight(height: stateLabel.frame.height, font: UIConstants.Fonts.appFont(.Semibold, 10)) ?? 0) + 16
        
        requirementView.isHidden = true
        additionReportView.isHidden = true
        approveClaimView.isHidden = true
        realClaimView.isHidden = true
        infoPaymentView.isHidden = true
        declineClaimView.isHidden = true
        downloadContactView.isHidden = true
        
        attachButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        downloadContactButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
    }
    
    override func initViews() {
        setupHeaderView()
    }
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        //        labelBaseTitle.text = "CONTRACT".localize() + " #\(claimId)" // " #\(contractId.prefix(6))"
        
        labelBaseTitle.frame = CGRect(x: UIConstants.widthConstraint(30), y: 0, width: 272.width, height: UIConstants.heightConstraint(21))
        
        labelBaseTitle.center.x = headerBaseView.center.x
        labelBaseTitle.center.y = leftBaseImage.center.y
        
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        rightBaseImage.image = UIImage(named: "ic_download_doc")?.withRenderingMode(.alwaysTemplate)
        rightBaseImage.tintColor = .appColor(.black)
        rightBaseImage.addTapGestureRecognizer {
            guard let model = self.model, !self.listFormClaim.isEmpty else { return }
            for item in self.listFormClaim {
                if LayoutBuilder.shared.canUseFormClaim(formClaim: item, model: model),
                    let file = item.file {
                    let vc = WebViewController()
                    vc.setUrl(url: API.STATIC_RESOURCE + file, canDownload: true)
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                }
            }
        }
    }
    
    private func showNotePopup() {
        if UserDefaults.standard.bool(forKey: Key.claimBenefitNote.rawValue) { return }
        UserDefaults.standard.set(true, forKey: Key.claimBenefitNote.rawValue)
        self.showCustomPopup2(messages: ["YOU_CAN_DOWNLOAD_AND".localize()], positions: [
            CGPoint(
                x: UIConstants.Layout.screenWidth - 252.width, // rightBaseImage.convert(rightBaseImage.frame.origin, to: view).x - 252,
                y: view.convert(rightBaseImage.frame.origin, to: view).y + 28
            )
        ], caretPos: [.init(x: 98.width, y: 0)], dialogWidth: 252) {
            
        }
    }
    
    @objc func pickImages() {
        AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [
            UIAlertAction(title: "TAKE_PHOTO".localize(), style: .default, handler: { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }),
            UIAlertAction(title: "CHOOSE_PHOTOS_FROM_DEVICE".localize(), style: .default, handler: { _ in
                if #available(iOS 14.0, *) {
                    self.present(self.phImagePicker, animated: true, completion: nil)
                }
                else {
                    self.imagePicker.sourceType = .photoLibrary
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            }),
            UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { _ in
                
            })], completion: {
                
            })
    }
    
    @objc private func didTapButton(_ button: BaseButton) {
        switch button {
        case attachButton:
            pickImages()
        case downloadContactButton:
            guard let model = model else { return }
            
            switch model.status {
            case ClaimProcessType.APPROVED.rawValue:
                let vc = ClaimAccountViewController()
                navigationController?.pushViewController(vc, animated: true)
                break
            case ClaimProcessType.PROCESSING.rawValue:
                break
            case ClaimProcessType.SENT_INFO.rawValue:
                break
            case ClaimProcessType.REJECT.rawValue:
                let vc = WebViewController()
                vc.setUrl(url: "https://krissirk0906.github.io/chatbox.html")
                navigationController?.pushViewController(vc, animated: true)
                break
            case ClaimProcessType.REQUIRE_UPDATE.rawValue:
                if model.requireUpdateStatus == 1 {
                    if linkPaperDocument.isEmpty {
                        return
                    }
                    let isFullPath = linkPaperDocument.contains("https://")
                    if let url = URL(string: (isFullPath ? "" : API.STATIC_RESOURCE) + linkPaperDocument) {
                        self.lockScreen()
                        FileDownloader.loadFileAsync(url: url) { (path, error) in
                            Logger.Logs(message: "PDF File downloaded to : \(path)")
                            // Create new notifcation content instance
                            let notificationContent = UNMutableNotificationContent()

                            // Add the content to the notification content
                            notificationContent.title = "Đã tải xuống thành công"
                            notificationContent.body = "Tài liệu được lưu vào folder Affina trong ứng dụng File"
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
                            UNUserNotificationCenter.current().add(request)
                            self.unlockScreen()
                        }
                    }
                    
                    return
                }
                
                
                if images.isEmpty { return }
                
                presenter.uploadImages(images: images)
                break
            default: break
            }
        default: break
        }
    }
    
    private func setClaimAmountLabel(_ amount: Int) {
        let priceText = "\(amount.addComma()) "
        let currencyText = "VND"
        let attrs2 = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.ExtraBold, 16)
        ] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: priceText, attributes: attrs2)
        let normalString = NSMutableAttributedString(string: currencyText)
        attributedString.append(normalString)
        self.claimAmountLabel.attributedText = attributedString
    }
}

// MARK: UITableViewDelegate
extension ClaimBenefitDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == requestPayemntTableView {
            return termsHeaders.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == requestPayemntTableView {
            if self.hiddenSections.contains(section) {
                return 0
            }
            return terms[section].count
        }
        if tableView == treatmentTableView {
            return treatmentTitles.count
        }
        if tableView == requestPayemntTableView {
            return 1
        }
        if tableView == infoPaymentTableView {
            return paymentTitles.count
        }
        return paymentTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == treatmentTableView {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DoubleColumnTableViewCell.cellId, for: indexPath) as? DoubleColumnTableViewCell else { return UITableViewCell() }
                cell.leftTitleLabel.text = treatmentTitles[indexPath.row]
                cell.setTitle(title: treatmentTitles[indexPath.row])
                cell.contentSeparator.backgroundAsset = "blueSlider"
                cell.showContentSeparator(true)
                cell.selectionStyle = .none
                if indexPath.row < treatmentDatas.count && indexPath.row == 0 {
                    cell.setText(text: treatmentDatas[indexPath.row])
                }
                return cell
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.cellId, for: indexPath) as? InfoTableViewCell else { return UITableViewCell() }
            cell.titleLabel.text = treatmentTitles[indexPath.row]
            if indexPath.row < treatmentDatas.count {
                cell.infoLabel.text = treatmentDatas[indexPath.row]
            }
            cell.separator.backgroundAsset = "blueSlider"
            return cell
        }
        if tableView == infoPaymentTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.cellId, for: indexPath) as? InfoTableViewCell else { return UITableViewCell() }
            cell.titleLabel.text = paymentTitles[indexPath.row]
            if indexPath.row < paymentDatas.count {
                cell.infoLabel.text = paymentDatas[indexPath.row]
            }
            cell.separator.backgroundAsset = "blueSlider"
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.cellId, for: indexPath) as? InfoTableViewCell else { return UITableViewCell() }
            cell.titleLabel.text = paymentTitles[indexPath.row]
            if indexPath.row < paymentDatas.count {
                cell.infoLabel.text = paymentDatas[indexPath.row]
            }
            cell.separator.backgroundAsset = "blueSlider"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UITableView.automaticDimension
    }
}

// MARK: UICollectionViewDatasource
extension ClaimBenefitDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uploads.count > 5 ? 5 : uploads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachedImageCollectionViewCell.cellId, for: indexPath) as? AttachedImageCollectionViewCell else { return UICollectionViewCell() }
        if let url = URL(string: API.STATIC_RESOURCE + uploads[indexPath.row].link) {
            CacheManager.shared.imageFor(url: url) { image, error in
                if error != nil {
                    Logger.Logs(event: .error, message: error!)
                    return
                }
                DispatchQueue.main.async {
                    cell.setImage(image)
                }
            }
        }
        let limit = uploads.count > 5 ? 5 : uploads.count
        if indexPath.row == limit - 1 {
            if uploads.count > 5 {
                cell.showMoreText(moreNumber: uploads.count - limit)
            }
        }
        else {
            cell.hideMoreText()
            cell.addImageView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 56, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        //        if indexPath.row == 0 {
        //            let viewController = TLPhotosPickerViewController()
        //            viewController.delegate = self
        //            self.present(viewController, animated: true, completion: nil)
        //        }
        //        else {
        //            previewImage.image = selectedAssets[indexPath.row - 1]
        //        }
    }
}

// UIImagePickerControllerDelegate
extension ClaimBenefitDetailViewController: UIImagePickerControllerDelegate {
    func convertBase64StringToImage(imageBase64String: String) -> UIImage {
        //        let imageData = Data(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        self.imagePicker.allowsEditing = false
        if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            image = img
        }
        else if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            image = img
        }
        
        images.append(image)
        
        picker.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                AlertService.showToast(message: "ADDED_IMAGES".localize().replace(string: "@a", replacement: "1"))
            }
        })
    }
    
    //Cancel pick image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ClaimBenefitDetailViewController: UINavigationControllerDelegate {
    
}

@available(iOS 14, *)
extension ClaimBenefitDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        phImagePicker.dismiss(animated: true)
        for itemProvider in results {
            if itemProvider.itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let uiImage = image as? UIImage, let safeSelf = self {
                        self?.images.append(uiImage)
                        if safeSelf.images.count == results.count {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                AlertService.showToast(message: "ADDED_IMAGES".localize().replace(string: "@a", replacement: "\(results.count)"))
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            AlertService.showToast(message: "NO_IMAGES".localize())
                        }
                    }
                }
            }
        }
    }
    
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

// MARK: ClaimBenefitDetailViewDelegate
extension ClaimBenefitDetailViewController: ClaimBenefitDetailViewDelegate {
    
    func showError(error: ApiError) {
        queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: "ERROR_HAPPENED".localize(), okTitle: "TRY_AGAIN".localize(), cancelTitle: "", okHandler: {
            self.hideBasePopup()
        }, handler: {})
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func lockUI() {
        lockScreen()
    }
    
    func updateSuccess() {
        AlertService.showToast(message: "UPDATE_SUCCESS".localize())
//        self.queueBasePopup2(icon: UIImage(named: "ic_check_circle"), title: "SUBMIT_REQUEST_SUCCESSFULLY".localize(), desc: "YOUR_REQUEST_HAS_BEEN".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "") {
//            self.hideBasePopup()
//            UIView.animate(withDuration: 0.25, delay: 0.25) {
//            } completion: { _ in
//                if self.canPopToViewController(CardViewController()) {
//                    self.popToViewController(CardViewController())
//                }
//                else {
//                    self.dismiss(animated: true) {
//                        let vc = CardViewController()
//                        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
//                    }
//                }
//            }
//        } handler: {
//        }
    }
    
    
    func uploadFilesSuccess(files: String) {
        guard let model = model else {
            showError(error: .otherError)
            return
        }
        do {
            let text = try JSON(data: (model.additionalDocument ?? "").data(using: .utf8) ?? Data())
            let typeId = text.arrayValue[0]["typeId"].stringValue
            
            let document = AdditionalDocument(id: model.id, listDocument: [AttachmentModel(type: typeId, attachments: files)])
            presenter.updateProofImages(document: document)
        } catch {
            Logger.Logs(event: .error, message: error.localizedDescription)
        }
    }
    
    // MARK: updateUI
    func updateUI(model: ClaimDetailModel) {
        self.model = model
        let data = model
        let claimType = ClaimType(rawValue: data.claimType) ?? ClaimType.LABOR_ACCIDENT
        switch claimType {
        case .LABOR_ACCIDENT:
            iconTypeImageView.image = UIImage(named: "ic_accident")
        case .TRAFFIC_ACCIDENT:
            iconTypeImageView.image = UIImage(named: "ic_accident")
        case .OUTPATIENT:
            iconTypeImageView.image = UIImage(named: "ic_drug_medicine")
        case .INPATIENT:
            iconTypeImageView.image = UIImage(named: "ic_bed")
        case .DENTISTRY:
            iconTypeImageView.image = UIImage(named: "ic_tooth")
        case .HOSPITALIZATION_ALLOWANCE:
            iconTypeImageView.image = UIImage(named: "ic_money")
        case .INCOME_SUPPORT:
            iconTypeImageView.image = UIImage(named: "ic_money")
        case .MATERNITY:
            iconTypeImageView.image = UIImage(named: "ic_pregnant")
        case .DEAD:
            iconTypeImageView.image = UIImage(named: "ic_rip")
        case .ILLNESS:
            iconTypeImageView.image = UIImage(named: "ic_bed")
        case .SUBSIDY_FOR_HOSPITAL_FEE_INCOME:
            iconTypeImageView.image = UIImage(named: "ic_money")
        case .DEATH_BY_ACCIDENT_ILLNESS:
            iconTypeImageView.image = UIImage(named: "ic_rip")
        }
        
        self.labelBaseTitle.text = "CONTRACT".localize() + " #\(data.contractObjectID)"
        self.treatmentDatas.append(contentsOf: ["\(String(data.hospitalizedDate/1000).timestampToFormatedDate(format: "dd/MM/yyyy"))@\(data.hospitalDischargeDate < 0 ? "-" : String(data.hospitalDischargeDate/1000).timestampToFormatedDate(format: "dd/MM/yyyy"))", data.placeOfTreatment, data.diagnostic, data.amountClaim.addComma(".")])
        if let bankName = data.bankName {
            self.paymentDatas.append(bankName)
        }
        if let accountName = data.accountName {
            self.paymentDatas.append(accountName)
        }
        if let accountNumberBank = data.accountNumberBank {
            self.paymentDatas.append(accountNumberBank)
        }
        if data.upload != nil {
            do {
                let files = try JSONDecoder().decode([File].self, from: (data.upload ?? "").data(using: .utf8)!)
                self.uploads = files
            } catch (let err) {
                Logger.Logs(event: .error, message: err)
            }
        }
        self.treatmentTableView.reloadData()
        self.paymentTableView.reloadData()
        self.proofCollectionView.reloadData()
        
        switch data.status {
        case ClaimProcessType.APPROVED.rawValue:
            self.stateLabel.setTitle(ClaimProcessType.APPROVED.string, for: .normal)
            self.stateLabel.setImage(UIImage(named: "ic_approved_state"), for: .normal)
            
            downloadContactView.show()
                downloadContactButton.setTitle(" \("CONTACT_US_REPLY".localize())".capitalized, for: .normal)
            downloadContactButton.borderWidth = 2
            downloadContactButton.borderColor = "grayBorder"
            downloadContactButton.backgroundColor = .white
            downloadContactButton.colorAsset = "subText"
            paymentView.hide()
            
            let date = "AFTER_7_DAYS".localize()
            let attrs = [
                NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 14)
            ] as [NSAttributedString.Key : Any]
            let attributedString = NSMutableAttributedString(string: date, attributes: attrs)
            let normalString = NSMutableAttributedString(string: "MONEY_WILL_BE_TRANSFERED".localize())
            let normalString2 = NSMutableAttributedString(string: "WORK_DAYS_TO_ACCOUNT".localize())
            attributedString.insert(normalString, at: 0)
            attributedString.append(normalString2)
            approveClaimLabel.attributedText = attributedString
            
            do {
                let text = try JSON(data: (data.benefitCost ?? "").data(using: .utf8) ?? Data()) // For debug logging()
                let compensationAmount = text.arrayValue[0]["compensationAmount"].intValue
                let unpaidReason = text.arrayValue[0]["UnpaidReason"].stringValue
                
                //                reasonLabel.attributedText = unpaidReason.htmlToAttributedString
                reasonLabel.text = unpaidReason
                
                if compensationAmount == data.amountClaim {
                    approveClaimView.show()
                }
                else {
                    realClaimView.show()
                    infoPaymentView.show()
                    
                    realClaimLabel.text = compensationAmount > data.amountClaim ? "ACTUAL_PAYMENT".localize() : "PARTIAL_PAYMENT_ONLY".localize()
                    setClaimAmountLabel(compensationAmount)
                    
                    let attrs = [
                        NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16)
                    ] as [NSAttributedString.Key : Any]
                    let attributedString = NSMutableAttributedString(string: "\(data.amountClaim.addComma("."))", attributes: attrs)
                    let normalString = NSMutableAttributedString(string: " VND")
                    attributedString.append(normalString)
                    requestAmountLabel.attributedText = attributedString
                    
                    let attrs2 = [
                        NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16)
                    ] as [NSAttributedString.Key : Any]
                    let attributedString2 = NSMutableAttributedString(string: "\(compensationAmount.addComma("."))", attributes: attrs2)
                    let normalString2 = NSMutableAttributedString(string: " VND")
                    attributedString2.append(normalString2)
                    realAmountLabel.attributedText = attributedString2
                }
                
            } catch {
                Logger.Logs(event: .error, message: error.localizedDescription)
            }
            break
        case ClaimProcessType.PROCESSING.rawValue:
            self.stateLabel.setTitle(ClaimProcessType.PROCESSING.string, for: .normal)
            self.stateLabel.setImage(UIImage(named: "ic_processing_state"), for: .normal)
            
            setClaimAmountLabel(data.amountClaim)
            break
        case ClaimProcessType.REJECT.rawValue:
            self.stateLabel.setTitle(ClaimProcessType.REJECT.string, for: .normal)
            self.stateLabel.setImage(UIImage(named: "ic_reject_state"), for: .normal)
            declineClaimView.show()
            
            downloadContactView.show()
            downloadContactButton.setTitle("CONTACT_US_REPLY".localize().capitalized, for: .normal)
            downloadContactButton.borderWidth = 2
            downloadContactButton.borderColor = "grayBorder"
            downloadContactButton.backgroundColor = .white
            downloadContactButton.colorAsset = "subText"
            
            do {
                let text = try JSON(data: (data.groupCost ?? "").data(using: .utf8) ?? Data()) // For debug logging()
                let unpaidReason = text.arrayValue[0]["unpaidReasonGroup"].stringValue
                
                rejectReasonLabel.text = unpaidReason
                
            } catch {
                Logger.Logs(event: .error, message: error.localizedDescription)
            }
            
            setClaimAmountLabel(data.amountClaim)
            break
        case ClaimProcessType.REQUIRE_UPDATE.rawValue:
            self.stateLabel.setTitle(ClaimProcessType.REQUIRE_UPDATE.string, for: .normal)
            self.stateLabel.setImage(UIImage(named: "ic_update_state"), for: .normal)
            
            if data.requireUpdateStatus == 1 {
                downloadContactButton.tintColor = .appColor(.whiteMain)
                downloadContactButton.setImage(UIImage(named: "ic_medicine")?.withRenderingMode(.alwaysTemplate), for: .normal)
                downloadContactButton.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 12)
                downloadContactButton.setTitle("DOWNLOAD_FORM".localize().capitalized, for: .normal)
                
                additionReportView.show()
                
                do {
//                    let text = try JSON(data: (data.additionalDocument ?? "").data(using: .utf8) ?? Data())
                    let paperDocument = try JSON(data: (data.paperDocument ?? "").data(using: .utf8) ?? Data())
                    let typeName = "" // text.arrayValue[0]["typeName"].stringValue
                    let dateStr = paperDocument.dictionaryValue["deadlineDate"]?.doubleValue ?? 0
                    
                    let date = Date(timeIntervalSince1970: dateStr/1000)
                    let attrs = [
                        NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 14)
                    ] as [NSAttributedString.Key : Any]
                    let attributedString = NSMutableAttributedString(string: "\(typeName) \("BEFORE_DAY".localize()) \("\(date.timeIntervalSince1970)".timestampToFormatedDate(format: "dd/MM/yyyy").components(separatedBy: "T")[0])", attributes: attrs)
                    let normalString = NSMutableAttributedString(string: "THE_INSURER_REQUIRES_YOU".localize())
                    attributedString.insert(normalString, at: 0)
                    
                    youNeedUpdateLabel2.attributedText = attributedString
                    
                    
                    linkPaperDocument = paperDocument.dictionaryValue["linkPaperDocument"]?.stringValue ?? ""
                    
                    officeNameLabel.text = paperDocument.dictionaryValue["building"]?.stringValue
                    phoneNumberLabel.text = "\("PHONE".localize()): \(paperDocument.dictionaryValue["phone"]?.stringValue ?? "")"
                    
                    let attrs2 = [
                        NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Regular, 14)
                    ] as [NSAttributedString.Key : Any]
                    let attributedString2 = NSMutableAttributedString(string: "\(paperDocument.dictionaryValue["address"]?.stringValue ?? "")", attributes: attrs2)
                    let normalString2 = NSMutableAttributedString(string: "\("ADDRESS".localize()): ")
                    attributedString2.insert(normalString2, at: 0)
                    addressLabel.attributedText = attributedString2
                    
                } catch {
                    Logger.Logs(event: .error, message: error.localizedDescription)
                }
                
            }
            else {
                downloadContactButton.setImage(nil, for: .normal)
                downloadContactButton.setTitle("UPDATE_DOCUMENTS".localize().capitalized, for: .normal)
                
                requirementView.show()
                
                do {
                    let text = try JSON(data: (data.additionalDocument ?? "").data(using: .utf8) ?? Data())
                    let typeName = text.arrayValue[0]["typeName"].stringValue
                    let dateStr = text.arrayValue[0]["deadlineDate"].doubleValue
                    
                    let date = Date(timeIntervalSince1970: dateStr/1000)
                    let attrs = [
                        NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 14)
                    ] as [NSAttributedString.Key : Any]
                    let attributedString = NSMutableAttributedString(string: "\(typeName) \("BEFORE_DAY".localize()) \("\(date.timeIntervalSince1970)".timestampToFormatedDate(format: "dd/MM/yyyy").components(separatedBy: "T")[0])", attributes: attrs)
                    let normalString = NSMutableAttributedString(string: "YOU_NEED_TO_UPDATE_DOCS".localize())
                    attributedString.insert(normalString, at: 0)
                    
                    youNeedUpdateLabel.attributedText = attributedString
                } catch {
                    Logger.Logs(event: .error, message: error.localizedDescription)
                }
                
            }
            
            downloadContactView.show()
            
            setClaimAmountLabel(data.amountClaim)
            
            break
        case ClaimProcessType.SENT_INFO.rawValue:
            self.stateLabel.setTitle(ClaimProcessType.SENT_INFO.string, for: .normal)
            self.stateLabel.setImage(UIImage(named: "ic_new_state"), for: .normal)
            setClaimAmountLabel(data.amountClaim)
            break
        default: break
        }
        
        stateLabel.sizeToFit()
        statusLabelWidthConstraint.constant = (stateLabel.title(for: .normal)?.widthWithConstrainedHeight(height: stateLabel.frame.height, font: UIConstants.Fonts.appFont(.ExtraBold, 10)) ?? 0) + 16 // + 42
        
        if self.paymentDatas.isEmpty {
            self.paymentTableView.hide(isImmediate: true)
        }
        else {
            self.paymentTableView.show()
        }
        
        self.dateLabel.text = "\(data.createdAt/1000)".timestampToFormatedDate(format: "dd.MM.yyyy")
        
        self.benefitLabel.text = claimType.string
        
    }
    
}

