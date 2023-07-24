//
//  ProofViewController.swift
//  affina
//
//  Created by Dylan on 21/09/2022.
//

import UIKit
import Photos

class ProofViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: BaseView!
    
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var downloadButton: BaseButton!
    
    @IBOutlet weak var benefitLabel: BaseLabel!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet weak var dateInTextField: TitleTextFieldBase!
    @IBOutlet weak var dateOutTextField: TitleTextFieldBase!
    @IBOutlet weak var placeTextField: TitleTextFieldBase!
    @IBOutlet weak var diagTextField: TitleTextFieldBase!
    @IBOutlet weak var moneyTextField: TitleTextFieldBase!
    

    @IBOutlet weak var checkBoxButton: BaseButton!
    @IBOutlet weak var attachButton: BaseButton!
    @IBOutlet weak var submitButton: BaseButton!
    
    @IBOutlet weak var attachedView: BaseView!
    @IBOutlet weak var attachedTableView: ContentSizedTableView!
    
    @IBOutlet weak var treatmentView: BaseView!
    @IBOutlet weak var treatmentTableView: ContentSizedTableView!
    
    
    private let dateInPickerView: UIDatePicker = UIDatePicker()
    private let dateOutPickerView: UIDatePicker = UIDatePicker()
    private var currentDatePickerView: UIDatePicker = UIDatePicker()
    
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var treatmentTableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTableTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var carvetView: BaseView!
    @IBOutlet weak var licenseView: BaseView!
    @IBOutlet weak var frontCarvetView: BaseView!
    @IBOutlet weak var backCarvetView: BaseView!
    @IBOutlet weak var frontCarvetImageView: UIImageView!
    @IBOutlet weak var backCarvetImageView: UIImageView!
    @IBOutlet weak var frontLicenseView: BaseView!
    @IBOutlet weak var backLicenseView: BaseView!
    @IBOutlet weak var frontLicenseImageView: UIImageView!
    @IBOutlet weak var backLicenseImageView: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    
    private var textField: TextFieldAnimBase!
    private var textFieldIndex = -1
    private var isCarvetFrontImageView: Bool = false
    private var isCarvetBackImageView: Bool = false
    private var isLicenseFrontImageView: Bool = false
    
    private var isUploadingCarvetFrontImage = false
    private var isUploadingCarvetBackImage = false
    private var isUploadingLicenseFrontImage = false
    private var isUploadingLicenseBackImage = false
    
    private var isAgree: Bool = false
    private var selectedCategory: Int = 0
    var activeBenefits :[String] = []
    var type: ClaimType = .LABOR_ACCIDENT
    var index: Int = 0
    var requestModel: ClaimRequestModel?
    var treatmentPlacesBaoMinhCurrent : BaoMinhProvider?
    var cardModel: CardModel?
    
    private var listImageClaimDetail: [ListSetupImageClaimDetail] = []
    
    private let listFormClaim: [ListSetupFormClaim] = LayoutBuilder.shared.getListFormClaim()
    
    private var treatmentPlaces: [CoSoYTeModel] = [] {
        didSet {
            treatmentView.isHidden = treatmentPlaces.isEmpty
            treatmentTableBottomConstraint.constant = treatmentPlaces.isEmpty ? -20 : 20
            treatmentTableView.reloadData()
        }
    }
    private var treatmentPlacesBaoMinh: [BaoMinhProvider] = [] {
        didSet {
            treatmentView.isHidden = treatmentPlacesBaoMinh.isEmpty
            treatmentTableBottomConstraint.constant = treatmentPlacesBaoMinh.isEmpty ? -20 : 20
            treatmentTableView.reloadData()
        }
    }
    private var images: [[UIImage]] = []
    private var currentStep: Int = -1
    private let categories: [[String]] = [
//        ["Tai nạn", "Tai nạn giao thông"],
//        ["Ngoại trú", "Nội trú"],
//        ["Nha khoa"],
//        ["Thai sản"],
//        ["Trợ cấp nằm viện", "Hỗ trợ thu nhập"],
//        ["Tử vong do tai nạn/bệnh"]
        [ClaimType.LABOR_ACCIDENT.string, ClaimType.TRAFFIC_ACCIDENT.string],
        [ClaimType.OUTPATIENT.string, ClaimType.INPATIENT.string],
        [ClaimType.DENTISTRY.string],
        [ClaimType.MATERNITY.string],
        [ClaimType.HOSPITALIZATION_ALLOWANCE.string, ClaimType.INCOME_SUPPORT.string],
        ["DEATH_BY_ACCIDENT_ILLNESS".localize()]
    ]
    private let claimTypes: [[ClaimType]] = [
        [.LABOR_ACCIDENT, .TRAFFIC_ACCIDENT],
        [.OUTPATIENT, .INPATIENT],
        [.DENTISTRY],
        [.MATERNITY],
        [.HOSPITALIZATION_ALLOWANCE, .INCOME_SUPPORT],
        [.DEAD]
    ]
    
    private let presenter = ProofViewPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBlurStatusBar()
        hideHeaderBase()
        containerBaseView.hide()

        view.backgroundColor = .appColor(.blueUltraLighter)
        
        presenter.delegate = self
        
        let rightView = UIView(frame: .init(x: 0, y: 0, width: 48, height: 24))
        let searchImageView = UIImageView(image: UIImage(named: "ic_search_black"))
        searchImageView.frame = .init(x: 10, y: 0, width: 20, height: 20)
        searchImageView.contentMode = .scaleAspectFit
        rightView.addSubview(searchImageView)
        rightView.addTapGestureRecognizer { [self] in
            if self.activeBenefits.count != 6{
                self.presenter.searchCoSoYTe1(keyword: self.placeTextField.textField.text ?? "")

            }else{
                self.presenter.searchCoSoYTe(keyword: self.placeTextField.textField.text ?? "")
            }
        }
        
        placeTextField.textField.rightView = rightView
        
        placeTextField.placeholder = ""
        
        if categories[index].count < 2 {
            categoryCollectionView.hide(isImmediate: true)
            benefitLabel.text = "BENEFIT".localize() + " \(categories[index][0])"
            benefitLabel.show()
        }
        else {
            benefitLabel.hide()
        }
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(UINib(nibName: InsuranceTypeCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: InsuranceTypeCollectionViewCell.cellId)
        
        attachedTableView.hide(isImmediate: true)
        attachedTableView.delegate = self
        attachedTableView.dataSource = self
        attachedTableView.register(UINib(nibName: ProofAttachedTableViewCell.nib, bundle: nil), forCellReuseIdentifier: ProofAttachedTableViewCell.cellId)
        
        imagePicker.delegate = self
        
        updateHeightConstraints()
        
        setupDatePicker(textField: dateInTextField, datePickerView: dateInPickerView)
        setupDatePicker(textField: dateOutTextField, datePickerView: dateOutPickerView)
        
        dateOutTextField.textField.clearButtonMode = .always
        dateOutTextField.textField.rightViewMode = .whileEditing
        
        setupTextFields()
        
//        if CacheManager.shared.isExistCacheWithKey(Key.treatmentPlaces.rawValue) {
//            ParseCache.parseCacheToArray(key: Key.treatmentPlaces.rawValue, modelType: CoSoYTeModel.self) { [weak self] result in
//                switch result {
//                case .success(let models):
//                    self?.treatmentPlaces = models
//                    DispatchQueue.main.async {
//                        self?.treatmentTableBottomConstraint.constant = models.isEmpty ? -20 : 20
//                        self?.treatmentTableView.reloadData()
//                    }
//                case .failure(let error):
//                    Logger.Logs(event: .error, message: error.localizedDescription)
//                }
//            }
//        }
        treatmentPlaces = []
        treatmentPlacesBaoMinh = []
        treatmentTableView.delegate = self
        treatmentTableView.dataSource = self
        treatmentTableView.register(UINib(nibName: TreatmentPlaceTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TreatmentPlaceTableViewCell.identifier)
        
        
        frontCarvetView.addTapGestureRecognizer {
            self.isCarvetFrontImageView = true
            self.isCarvetBackImageView = false
            self.pickID()
        }
        backCarvetView.addTapGestureRecognizer {
            self.isCarvetFrontImageView = false
            self.isCarvetBackImageView = true
            self.pickID()
        }
        
        frontLicenseView.addTapGestureRecognizer {
            self.isLicenseFrontImageView = true
            self.pickID()
        }
        backLicenseView.addTapGestureRecognizer {
            self.isLicenseFrontImageView = false
            self.pickID()
        }
        
        backButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        checkBoxButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        attachButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
        
        if checkInfoIsFilled() {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        
        
        if let cardModel = cardModel {
            let list = LayoutBuilder.shared.getListImageClaim()
            for item in list {
                if LayoutBuilder.shared.canUseImageClaim(imageClaim: item, cardModel: cardModel, claimType: type) {
                    listImageClaimDetail = item.listImageClaimDetail ?? []
                    break
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        if images.count >= headers[index][selectedCategory].count {
        if images.count >= listImageClaimDetail.count {
            disableAttachButton()
        }
        if self.checkInfoIsFilled() {
            self.enableSubmitButton()
        }
        else {
            self.disableSubmitButton()
        }
        
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        scrollViewBottomConstraint.constant = 0
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollViewBottomConstraint.constant = keyboardSize.height
            let yOffset = (textField?.convert(textField?.frame.origin ?? .zero, to: contentView).y ?? 0)
            scrollView.setContentOffset(.init(x: 0, y: yOffset - keyboardSize.height + 74), animated: true)
        }
    }
    
    private func findEmptyProofIndex(oldIndex: Int = -1) -> Int {
        var index = -1
        for i in 0..<images.count {
            if images[i].isEmpty && oldIndex < i {
                index = i
                break
            }
        }
        //        if index == -1 && headers[self.index][selectedCategory].count > images.count {
        if index == -1 && listImageClaimDetail.count > images.count {
            index = images.count
        }
        currentStep = index
        return index
    }
    
    @objc private func didTapButton(_ sender: BaseButton) {
        if textField != nil {
            textField.resignFirstResponder()
        }
        switch sender {
        case backButton:
                queueBasePopup2(icon: UIImage(named: "ic_warning"), title: "YOUR_PROFILE_WILL_NOT".localize(), desc: "YOUR_INFORMATION_WILL_NOT".localize(), okTitle: "STAY".localize(), cancelTitle: "EXIT".localize()) {
                self.hideBasePopup()
            } handler: {
                self.popViewController()
            }
            
        case downloadButton:
//            var urlString = "https://static.affina.com.vn/affinastatic/MAU_GYCBT_Topup_Individual.docx" // live
//            if API.networkEnvironment == .live {}
//            else {}
            guard let model = self.cardModel, !self.listFormClaim.isEmpty else { return }
            for item in self.listFormClaim {
                if LayoutBuilder.shared.canUseFormClaim(formClaim: item, model: model),
                    let file = item.file {
                    lockScreen()
                    guard let url = URL(string: API.STATIC_RESOURCE + file) else {
                        
                        self.unlockScreen()
                        return
                    }
                    print(url)
                    FileDownloader.loadFileAsync(url: url) { (path, error) in
                        Logger.Logs(message: "PDF File downloaded to : \(path)")
                        self.unlockScreen()
                    }
                    break
                }
            }
            break
        case checkBoxButton :
            isAgree.toggle()
            checkBoxButton.setImage(isAgree ? UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate) : nil, for: .normal)
            checkBoxButton.backgroundColor = .appColor(isAgree ? .blueMain : .whiteMain)
            if checkInfoIsFilled() {
                enableSubmitButton()
            }
            else {
                disableSubmitButton()
            }
            break
            // MARK: attachButton
        case attachButton:
            //                if images.count >= headers[index][selectedCategory].count {
            if images.count >= listImageClaimDetail.count {
                disableAttachButton()
                return
            }
            let step = findEmptyProofIndex()
            let popup = SampleAccidentReportView()
            popup.setTitleNoteSampleLabel(imageUrl: getProofImage(step: step), title: getProofTitle(step: step)// headers[index][selectedCategory][step]
                                          , note: getProofContent(step: step)) // noteDict[headers[index][selectedCategory][step]] ?? "")
            popup.setNopeButtonText(getProofSkipText(step: step))
            popup.downloadCallback = {
                let urlString = self.getProofFile(step: step)
                Logger.Logs(message: urlString)
                guard let url = URL(string: urlString) else { return }
                self.lockScreen()
                FileDownloader.loadFileAsync(url: url) { (path, error) in
                    Logger.Logs(message: "PDF File downloaded to : \(path)")
                    self.unlockScreen()
                }
            }
            
            popup.uploadCallback = {
                let vc = PhotoGalleryViewController()
                vc.required = self.listImageClaimDetail[step].requireImage ?? 0
                vc.delegate = self
                vc.isCameraAllowed = true
                vc.claimType = self.claimTypes[self.index][self.selectedCategory]
                vc.header = self.listImageClaimDetail[step].name ?? "-" // self.headers[self.index][self.selectedCategory][step]
                vc.step = step
                vc.cardModel = self.cardModel
                self.present(vc, animated: true, completion: nil)
            }
            popup.captureCallback = {
                var headers = [String]()
                var requireds = [Int]()
//                for i in 0..<self.headers[self.index][self.selectedCategory].count {
                for i in 0..<self.listImageClaimDetail.count {
                    if i >= step {
                        if i >= self.images.count || (i < self.images.count && self.images[i].isEmpty) {
//                            headers.append(self.headers[self.index][self.selectedCategory][i])
//                            requireds.append(self.required[self.index][self.selectedCategory][i])
                            headers.append(self.listImageClaimDetail[i].name ?? "-")
                            requireds.append(self.listImageClaimDetail[i].requireImage ?? 0)
                        }
                    }
                }
                let vc = CameraScanViewController()
                vc.headers = headers
                vc.required = requireds // self.required[self.index][self.selectedCategory]
                vc.step = step
                vc.cardModel = self.cardModel
                vc.claimType = self.claimTypes[self.index][self.selectedCategory]
                vc.backCallBack = {
//                    for _ in self.images.count..<self.headers[self.index][self.selectedCategory].count{
                    for _ in self.images.count..<self.listImageClaimDetail.count{
                        self.images.append([])
                    }
                    self.attachedTableView.show()
                    self.attachedTableView.reloadData()
                }
                vc.addImageCallBack = { [weak self] images, step in
                    guard let self = self else { return }
//                    for i in 0..<self.headers[self.index][self.selectedCategory].count {
                    for i in 0..<self.listImageClaimDetail.count {
                        if headers.count == 1 {
                            if i < self.images.count {
                                self.images[i] = images
                            }
                            else {
                                self.images.append(images)
                            }
                        }
//                        if self.headers[self.index][self.selectedCategory][i] == headers[step-1] {
                        else if self.listImageClaimDetail[i].name == headers[step-1] {
                            if i < self.images.count {
                                self.images[i] = images
                            }
                            else {
                                self.images.append(images)
                            }
                        }
                        
                    }
                    self.attachedTableView.show()
                    self.attachedTableView.reloadData()
                }
                self.hideBottomSheet(animated: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            popup.showUploadCaptureButtons()
//            if self.required[self.index][self.selectedCategory][step] == 0 {
            if self.listImageClaimDetail[step].requireImage == 0 {
                popup.nopeCallback = {
                    self.hideBottomSheet(animated: false)
//                    if self.images.count < self.required[self.index][self.selectedCategory].count {
                    if self.images.count < self.listImageClaimDetail.count {
                        if self.images.count <= step {
                            self.images.append([])
                        }
                        else {
                            self.images[step] = []
                        }
                        if self.findEmptyProofIndex(oldIndex: step) != -1 {
                            self.showSamplePopup(step: self.findEmptyProofIndex(oldIndex: step))
                        }
                        self.attachedTableView.show()
                        self.attachedTableView.reloadData()
                    }
                    
//                    if self.images.count >= self.headers[self.index][self.selectedCategory].count {
                    if self.images.count >= self.listImageClaimDetail.count {
                        self.disableAttachButton()
                        return
                    }
                    
                }
                popup.showNopeButton()
            }
            
            self.bottomSheet.topView.show()
            bottomSheet.setContentForBottomSheet(popup)
            setNewBottomSheetHeight(760.height)
            showBottomSheet(animated: true)
        case submitButton:
//            let requireNumber = required[index][selectedCategory].reduce(0, +)
            var requireNumber = 0
            for el in listImageClaimDetail {
                requireNumber += el.requireImage ?? 0
            }
            if requireNumber > images.count {
                return
            }
            
            requestModel?.diagnostic = diagTextField.textField.text
            requestModel?.amountClaim = Int(moneyTextField.textField.text?.replace(string: ",", replacement: "") ?? "0") ?? 0
            if activeBenefits.count != 6 {
                    self.requestModel?.placeOfTreatment = treatmentPlacesBaoMinhCurrent?.code
            }else{
                requestModel?.placeOfTreatment = placeTextField.textField.text
            }
            let vc = ClaimAccountViewController()
            vc.requestModel = requestModel
            vc.images = images.flatMap({ $0 })
            vc.benefit = categories[index][selectedCategory]
            if !licenseView.isHidden {
                if frontCarvetImageView.image != nil {
                    vc.images.append(frontCarvetImageView.image!)
                }
                if backLicenseImageView.image != nil {
                    vc.images.append(backLicenseImageView.image!)
                }
            }
            if !carvetView.isHidden {
                if frontLicenseImageView.image != nil {
                    vc.images.append(frontLicenseImageView.image!)
                }
                if backCarvetImageView.image != nil {
                    vc.images.append(backCarvetImageView.image!)
                }
            }
            navigationController?.pushViewController(vc, animated: true)
            break
        default: break
        }
    }
    
    private func showSamplePopup(step: Int) {
        let popup = SampleAccidentReportView()
        popup.setTitleNoteSampleLabel(imageUrl: getProofImage(step: step), title: getProofTitle(step: step) // headers[index][selectedCategory][step]
                                      , note: getProofContent(step: step)) // noteDict[headers[index][selectedCategory][step]] ?? "")

        popup.setNopeButtonText(getProofSkipText(step: step))
        popup.downloadCallback = {
            let urlString = self.getProofFile(step: step)
            Logger.Logs(message: urlString)
            guard let url = URL(string: urlString) else { return }
            self.lockScreen()
            FileDownloader.loadFileAsync(url: url) { (path, error) in
                Logger.Logs(message: "PDF File downloaded to : \(path)")
                self.unlockScreen()
//                DispatchQueue.main.async {
//                    self.queueBasePopup(icon: UIImage(named: "ic_check_circle"), title: "Thành công", desc: "Tải xuống thành công!", okTitle: "AGREE".localize(), cancelTitle: "") {
//                        self.hideBasePopup()
//                    } handler: {
//                    }
//                }
            }
        }
        popup.uploadCallback = {
            let vc = PhotoGalleryViewController()
            vc.delegate = self
            vc.isCameraAllowed = true
            vc.claimType = self.claimTypes[self.index][self.selectedCategory]
            vc.header = self.listImageClaimDetail[step].name ?? "-" // self.headers[self.index][self.selectedCategory][step]
            vc.step = step
            vc.cardModel = self.cardModel
            self.present(vc, animated: true, completion: nil)
        }
        popup.captureCallback = {
            var headers: [String] = []
            var requireds: [Int] = []
//            for i in step..<self.headers[self.index][self.selectedCategory].count {
            for i in step..<self.listImageClaimDetail.count {
                if i >= self.images.count || (i < self.images.count && self.images[i].isEmpty) {
//                    headers.append(self.headers[self.index][self.selectedCategory][i])
//                    requireds.append(self.required[self.index][self.selectedCategory][i])
                    headers.append(self.listImageClaimDetail[i].name ?? "-")
                    requireds.append(self.listImageClaimDetail[i].requireImage ?? 0)
                }
            }
            let vc = CameraScanViewController()
            vc.headers = headers
            vc.required = requireds
            vc.step = step
            vc.cardModel = self.cardModel
            vc.claimType = self.claimTypes[self.index][self.selectedCategory]
            
            vc.backCallBack = {
//                for _ in self.images.count..<self.headers[self.index][self.selectedCategory].count {
                for _ in self.images.count..<self.listImageClaimDetail.count {
                    self.images.append([])
                }
                self.attachedTableView.show()
                self.attachedTableView.reloadData()
            }
            
            vc.addImageCallBack = { [weak self] images, step in
                guard let self = self else { return }
                if step < self.images.count && !self.images[step].isEmpty {
                    self.images[step].append(contentsOf: images)
                }
                else {
                    self.images.append(images)
                }
                self.attachedTableView.show()
                self.attachedTableView.reloadData()
            }
            self.hideBottomSheet(animated: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        popup.showUploadCaptureButtons()
//        if self.required[self.index][self.selectedCategory][step] == 0 {
        if self.listImageClaimDetail[step].requireImage == 0 {
            popup.nopeCallback = {
                self.hideBottomSheet(animated: false)
//                if self.images.count < self.required[self.index][self.selectedCategory].count {
                if self.images.count < self.listImageClaimDetail.count {
                    self.images.append([])
                    self.attachedTableView.show()
                    self.attachedTableView.reloadData()
                    
//                    if self.images.count >= self.headers[self.index][self.selectedCategory].count {
                    if self.images.count >= self.listImageClaimDetail.count {
                        self.disableAttachButton()
                    }
//                    if self.images.count == self.required[self.index][self.selectedCategory].count {
                    if self.images.count == self.listImageClaimDetail.count {
                        return
                    }
                    
                    if self.findEmptyProofIndex(oldIndex: step) != -1 {
                        self.showSamplePopup(step: self.findEmptyProofIndex(oldIndex: step))
                    }
                }
                
            }
            popup.showNopeButton()
            
//            if images.count >= headers[index][selectedCategory].count {
            if images.count >= listImageClaimDetail.count {
                disableAttachButton()
                return
            }
        }
        
        bottomSheet.topView.show()
        bottomSheet.setContentForBottomSheet(popup)
        setNewBottomSheetHeight(760.height)
        showBottomSheet(animated: true)
    }
    
    private func updateHeightConstraints() {
        if type == .TRAFFIC_ACCIDENT || type == .INCOME_SUPPORT {
            imageTableTopConstraint.constant = 60 + carvetView.frame.height + licenseView.frame.height
            carvetView.show()
            licenseView.show()
        }
        else {
            imageTableTopConstraint.constant = 20
            carvetView.hide()
            licenseView.hide()
        }
    }
    
    private func getProofImage(step: Int) -> String {
        var imageString: String = ""
        for el in listImageClaimDetail {
            if let orderImage = el.orderImage, orderImage == (step + 1) {
                imageString = API.STATIC_RESOURCE + (el.image ?? "")
                return imageString
            }
        }
        return imageString
    }
    
    private func getProofFile(step: Int) -> String {
        var fileString: String = ""
        for el in listImageClaimDetail {
            if let orderImage = el.orderImage, orderImage == (step + 1) {
                fileString = API.STATIC_RESOURCE + (el.file ?? "")
                return fileString
            }
        }
        return fileString
    }
    
    private func getProofTitle(step: Int) -> String {
        var title: String = "-"
        for el in listImageClaimDetail {
            if let orderImage = el.orderImage, orderImage == (step + 1) {
                title = el.name ?? "-"
                return title
            }
        }
        return title
    }
    private func getProofContent(step: Int) -> String {
        var content: String = "-"
        for el in listImageClaimDetail {
            if let orderImage = el.orderImage, orderImage == (step + 1) {
                content = el.content ?? "-"
                return content
            }
        }
        return content
    }
    
    private func getProofSkipText(step: Int) -> String {
        var text: String = "SKIP".localize()
        for el in listImageClaimDetail {
            if let orderImage = el.orderImage, orderImage == (step + 1) {
                text = el.textButtonSkip ?? "SKIP".localize()
                return text
            }
        }
        return text
    }
    
    private func setupDatePicker(textField: TitleTextFieldBase, datePickerView: UIDatePicker) {
        textField.rightIconView.tintColor = .appColor(.whiteMain)
        
        datePickerView.locale = NSLocale(localeIdentifier: "vi_VN") as Locale
        datePickerView.backgroundColor = UIColor.appColor(.whiteMain)
        datePickerView.date = Date()
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = Date()
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        textField.rightView.addTapGestureRecognizer {
            textField.textField.becomeFirstResponder()
            self.currentDatePickerView = datePickerView
        }
        
        textField.textField.inputView = datePickerView
        let doneToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "DONE".localize(), style: .done, target: self, action: #selector(datePickerValueDone))
        let items: [UIBarButtonItem] = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        textField.textField.inputAccessoryView = doneToolbar
    }
    
    @objc private func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "vi_VN")
        
        textField.text = dateFormatter.string(from: self.currentDatePickerView.date)
        if currentDatePickerView == dateInPickerView {
            requestModel?.hospitalizedDate = currentDatePickerView.date.timeIntervalSince1970 * 1000
            dateOutPickerView.minimumDate = currentDatePickerView.date
            dateOutPickerView.date = currentDatePickerView.date
            dateOutTextField.textField.text = nil
        }
        else if currentDatePickerView == dateOutPickerView {
            requestModel?.hospitalDischargeDate = currentDatePickerView.date.timeIntervalSince1970 * 1000
        }
        textFieldDidChange(textField)
    }
    
    @objc private func datePickerValueDone() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "vi_VN")
        
        textField.text = dateFormatter.string(from: self.currentDatePickerView.date)
        requestModel?.hospitalizedDate = currentDatePickerView.date.timeIntervalSince1970 * 1000
        dateOutPickerView.minimumDate = currentDatePickerView.date
        dateOutPickerView.date = currentDatePickerView.date
        if currentDatePickerView == dateInPickerView {
            dateOutTextField.textField.text = nil
        }
        //        else if currentDatePickerView == dateOutPickerView {
        //            for (i, header) in headers[index][selectedCategory].enumerated() {
        //                if header == "Giấy ra viện" && self.required[index][selectedCategory][i] == 1 {
        //                    textField.text = dateFormatter.string(from: self.currentDatePickerView.date)
        //                }
        //            }
        //        }
        textFieldDidChange(textField)
        textField.resignFirstResponder()
    }
    
}

// MARK: PhotoGalleryDelegate
extension ProofViewController: PhotoGalleryDelegate {
    func dismissPhotoGallery(withPHAssets: [PHAsset]) {
        
        if self.images.count <= currentStep {
            self.images.append(withPHAssets.map({ PhotoManager.getAssetThumbnail(asset: $0) ?? UIImage() }))
        }
        else {
            self.images[currentStep] = withPHAssets.map({ PhotoManager.getAssetThumbnail(asset: $0) ?? UIImage() })
        }
        
        self.attachedTableView.show()
        self.attachedTableView.reloadData(
        )
        if checkInfoIsFilled() {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
        
        hideBottomSheet()
        if self.findEmptyProofIndex(oldIndex: currentStep) != -1 {
            self.showSamplePopup(step: self.findEmptyProofIndex(oldIndex: currentStep))
        }
        
//        if self.images.count >= self.headers[self.index][self.selectedCategory].count {
        if self.images.count >= self.listImageClaimDetail.count {
            self.disableAttachButton()
            return
        }
    }
    
    func photoGalleryDidCancel() {
        hideBottomSheet(animated: true)
//        for _ in self.images.count..<self.headers[self.index][self.selectedCategory].count {
        for _ in self.images.count..<self.listImageClaimDetail.count {
            self.images.append([])
        }
        //                self.images = Array(repeating: [UIImage](), count: self.headers[self.index][self.selectedCategory].count)
        self.attachedTableView.show()
        self.attachedTableView.reloadData()
    }
}

// MARK: UIImagePickerControllerDelegate
extension ProofViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func convertBase64StringToImage(imageBase64String: String) -> UIImage {
        //        let imageData = Data(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    @objc func pickID() {
        AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [
            UIAlertAction(title: "TAKE_PHOTO".localize(), style: .default, handler: { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }),
            UIAlertAction(title: "CHOOSE_PHOTOS_FROM_DEVICE".localize(), style: .default, handler: { _ in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }),
            UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { _ in
                self.isCarvetFrontImageView = false
                self.isCarvetBackImageView = false
                self.isLicenseFrontImageView = false
            })], completion: {
                
            })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        if isCarvetFrontImageView {
            self.frontCarvetImageView.image = image
            self.frontCarvetImageView.show()
        }
        else if isCarvetBackImageView {
            backCarvetImageView.image = image
            backCarvetImageView.show()
        }
        else if isLicenseFrontImageView {
            self.frontLicenseImageView.image = image
            self.frontLicenseImageView.show()
        }
        else {
            backLicenseImageView.image = image
            backLicenseImageView.show()
        }
        
        self.isCarvetFrontImageView = false
        self.isCarvetBackImageView = false
        self.isLicenseFrontImageView = false
        
        self.imagePicker.allowsEditing = false
        if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            image = img
        }
        else if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            image = img
        }
        
        if checkInfoIsFilled() {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Cancel pick image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

// MARK: UITableViewDelegate
extension ProofViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == treatmentTableView {
            if activeBenefits.count != 6{
                return treatmentPlacesBaoMinh.isEmpty ? 0 : (treatmentPlacesBaoMinh.count < 3 ? treatmentPlacesBaoMinh.count : 3)
            }else{
                return treatmentPlaces.isEmpty ? 0 : (treatmentPlaces.count < 3 ? treatmentPlaces.count : 3)
            }
        }
        return images.count // images.isEmpty ? 0 : headers[type].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == treatmentTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TreatmentPlaceTableViewCell.identifier, for: indexPath) as? TreatmentPlaceTableViewCell else { return UITableViewCell() }
            if activeBenefits.count != 6{
                cell.placeLabel.text = treatmentPlacesBaoMinh[indexPath.row].name
                
            }else{
                cell.placeLabel.text = treatmentPlaces[indexPath.row].name
            }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProofAttachedTableViewCell.cellId, for: indexPath) as? ProofAttachedTableViewCell else { return UITableViewCell() }
        //        cell.titleLabel.text = "\(headers[index][selectedCategory][indexPath.row].uppercased()) (\(images[indexPath.row].count))"
        cell.titleLabel.text = "\(listImageClaimDetail[indexPath.row].name ?? "-") (\(images[indexPath.row].count))"
                cell.images = images[indexPath.row]
                cell.images.insert(UIImage(), at: 0)
                cell.step = indexPath.row
        
                cell.cardModel = cardModel
        
                cell.claimType = self.claimTypes[self.index][self.selectedCategory]
                cell.presentCallBack = { vc in
                    self.present(vc, animated: true, completion: nil)
                }
                cell.addImageCallBack = { images in
                    self.images[indexPath.row] = images
                    if !self.images[indexPath.row].isEmpty {
                        self.images[indexPath.row].removeFirst()
                    }
                    self.attachedTableView.reloadData()
                }
                cell.changeImageCallBack = { index in
                    let vc = ChangeImageViewController()
                    vc.claimType = self.claimTypes[self.index][self.selectedCategory]
                    vc.headers = self.listImageClaimDetail.map({ $0.name ?? "-" }) // self.headers[self.index][self.selectedCategory]
                    vc.header = self.listImageClaimDetail[indexPath.row].name ?? "-" // self.headers[self.index][self.selectedCategory][indexPath.row]
                    vc.selectedAssets = self.images[indexPath.row]
                    vc.currentImageIndex = index - 1
                    vc.addImageCallBack = { [weak self] images in
                        self?.images[indexPath.row] = images
                        self?.attachedTableView.reloadData()
                    }
                    vc.cardModel = self.cardModel
                    vc.step = indexPath.row
                    self.navigationController?.pushViewController(vc, animated: true)
                }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == treatmentTableView {
            
            if activeBenefits.count != 6{
                placeTextField.textField.text = treatmentPlacesBaoMinh[indexPath.row].name
                treatmentPlacesBaoMinhCurrent = treatmentPlacesBaoMinh[indexPath.row]
            }else{
                placeTextField.textField.text = treatmentPlaces[indexPath.row].name
            }
            treatmentView.isHidden = true
            treatmentTableBottomConstraint.constant = -20
            treatmentPlaces = []
            treatmentPlacesBaoMinh = []
            treatmentTableView.reloadData()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ProofViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[index].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InsuranceTypeCollectionViewCell.cellId, for: indexPath) as? InsuranceTypeCollectionViewCell else { return UICollectionViewCell() }
        cell.nameLabel.text = categories[index][indexPath.row]
        if selectedCategory == indexPath.row {
            cell.setSelected()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InsuranceTypeCollectionViewCell, selectedCategory != indexPath.row else { return }
        
        selectedCategory = indexPath.row
        type = claimTypes[index][selectedCategory]
        
        listImageClaimDetail = []
        if let cardModel = cardModel {
            let list = LayoutBuilder.shared.getListImageClaim()
            for item in list {
                if LayoutBuilder.shared.canUseImageClaim(imageClaim: item, cardModel: cardModel, claimType: type) {
                    listImageClaimDetail = item.listImageClaimDetail ?? []
                    break
                }
            }
        }
        
        images = []
        
        attachedTableView.reloadData()
        enableAttachButton()
        
        if listImageClaimDetail.isEmpty {
            disableAttachButton()
        }
        
        updateHeightConstraints()
        for i in 0..<categories[index].count {
            cell.setSelected()
            if i != indexPath.row {
                if let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? InsuranceTypeCollectionViewCell { cell.setUnSelected() }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: categories[index][indexPath.row].widthWithConstrainedHeight(height: 48, font: UIConstants.Fonts.appFont(.Bold, 16)) + 40, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIPadding.size8
    }
}

// MARK: EXT ProofViewController
extension ProofViewController {
    private func disableAttachButton() {
        attachButton.isUserInteractionEnabled = false
        attachButton.isEnabled = false
        attachButton.backgroundColor = .appColor(.blueSlider)
        attachButton.layer.opacity = 0.75
        attachButton.setTitleColor(.appColor(.whiteMain), for: .normal)
    }
    
    private func enableAttachButton() {
        attachButton.isUserInteractionEnabled = true
        attachButton.isEnabled = true
        attachButton.backgroundColor = .appColor(.blueMain)
        attachButton.layer.opacity = 1
        attachButton.setTitleColor(.appColor(.whiteMain), for: .normal)
    }
    
    private func enableSubmitButton() {
        submitButton.isUserInteractionEnabled = true
        submitButton.isEnabled = true
        submitButton.backgroundColor = .appColor(.pinkMain)
        submitButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        submitButton.dropShadow(color: UIColor.appColor(.pinkLong) ?? UIColor(hex: "FF52DB"), opacity: 0.25, offset: .init(width: 0, height: 8), radius: 16, scale: true)
    }
    
    private func disableSubmitButton() {
        submitButton.isUserInteractionEnabled = false
        submitButton.isEnabled = false
        submitButton.backgroundColor = .appColor(.pinkUltraLighter)
        submitButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        submitButton.clearShadow()
    }
    
    private func checkInfoIsFilled() -> Bool {
        let dateInCount = dateInTextField.textField.count
        let dateOutCount = dateOutTextField.textField.count
        let placeCount = placeTextField.textField.count
        let diagCount = diagTextField.textField.count
        let moneyCount = moneyTextField.textField.count
        
//        let requireNumber = self.required[index][selectedCategory].reduce(0, +)
        var requireNumber = 0
        for el in listImageClaimDetail {
            requireNumber += el.requireImage ?? 0
        }
        
        var uploadedRequiredImages = 0
        for i in 0..<images.count {
//            if self.required[index][selectedCategory][i] == 1 && !images[i].isEmpty {
            if self.listImageClaimDetail[i].requireImage == 1 && !images[i].isEmpty {
                uploadedRequiredImages += 1
            }
            //            if !images[i].isEmpty {
            //                uploadedRequiredImages += 1
            //            }
        }
        
        let frontCarvet = frontCarvetImageView.image != nil
        let backCarvet = backCarvetImageView.image != nil
        let frontLicense = frontLicenseImageView.image != nil
        let backLicense = backLicenseImageView.image != nil
        
        let validation = dateInCount > 0 && placeCount > 0 && diagCount > 0 && moneyCount > 0  && isAgree && requireNumber <= uploadedRequiredImages // images.count
        && ((type == .TRAFFIC_ACCIDENT || type == .INCOME_SUPPORT) ? (frontCarvet && backCarvet && frontLicense && backLicense): true)
        
//        for (i, str) in headers[index][selectedCategory].enumerated() {
        for el in listImageClaimDetail {
//            if str == "Giấy ra viện" && self.required[index][selectedCategory][i] == 1 {
            if el.name == "DISCHARGE_PAPER".localize() && el.requireImage == 1 {
                return validation && dateOutCount > 0
            }
        }
        
        return validation
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == placeTextField.textField {
            presenter.searchCoSoYTe(keyword: textField.text ?? "")
        }
        return true
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard !dateInTextField.textField.isEmpty(),
              //              !dateOutTextField.textField.isEmpty(),
              !placeTextField.textField.isEmpty(),
              !diagTextField.textField.isEmpty(),
              !moneyTextField.textField.isEmpty(),
              checkInfoIsFilled() else {
            disableSubmitButton()
            return
        }
        enableSubmitButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //        guard var phoneNumber = phoneTextField.textField.text?.replace(string: " ", replacement: ""),
        //              let cccd = cccdTextField.textField.text else { return false }
        //
        //        let characterCount = phoneNumber.count
        //        let phoneCount = (characterCount + (string == "" ? -1 : 1))
        //        let cccdCount = (cccd.count + (string == "" ? -1 : 1))
        //        //        var count = string == "" ? -1 : 1
        //
        //        if textField == phoneTextField.textField {
        //            if string == "" {
        //                phoneNumber.removeLast()
        //            }
        //            if (phoneCount == 3 || phoneCount == 6) && string != "" {
        //                phoneTextField.textField.text = (phoneTextField.textField.text ?? "") + " "
        //            }
        //            return phoneCount <= 12 // true
        //        }
        //        else if textField == cccdTextField.textField {
        //            if cccdCount % 4 == 0 && string != "" {
        //                cccdTextField.textField.text = (cccdTextField.textField.text ?? "") + (cccdCount <= 14 ? " " : "")
        //            }
        //            if cccdCount > 0 && checkInfoIsFilled() {
        //                enableSubmitButton()
        //            }
        //            else {
        //                disableSubmitButton()
        //            }
        //            if identityType != .passport {
        //                return cccdCount <= 15 // 12 + 3 space
        //            }
        //            return cccdCount <= 10 || string == ""
        //        }
        
        return true
    }
    
    private func setupTextFields() {
        dateInTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        dateOutTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        placeTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        diagTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        moneyTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        dateInTextField.textField.delegate = self
        dateOutTextField.textField.delegate = self
        placeTextField.textField.delegate = self
        diagTextField.textField.delegate = self
        moneyTextField.textField.delegate = self
        moneyTextField.textField.keyboardType = .numberPad
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case dateInTextField.textField:
            dateInTextField.hideError()
            if textField.isEmpty() {
                dateInTextField.showError("Vui lòng chọn ngày khám/nhập viện!")
            }
            break
        case dateOutTextField.textField:
            dateOutTextField.hideError()
            if textField.isEmpty() {
//                for (i, str) in headers[index][selectedCategory].enumerated() {
                for el in listImageClaimDetail {
                    if el.name == "DISCHARGE_PAPER".localize() && el.requireImage == 1 {
                        dateOutTextField.showError("PLEASE_SELECT_DISCHARGE_DAY".localize())
                        break
                    }
                }
            }
            break
        case placeTextField.textField:
            placeTextField.hideError()
            if textField.isEmpty() {
                placeTextField.showError("PLEASE_INPUT_PLACE".localize())
            }
            break
        case diagTextField.textField:
            diagTextField.hideError()
            if textField.isEmpty() {
                diagTextField.showError("PLEASE_INPUT_DOCTOR_DIAGNOSIS".localize())
            }
            break
        case moneyTextField.textField:
            moneyTextField.hideError()
            if textField.isEmpty() {
                moneyTextField.showError("PLEASE_INPUT_MONEY_VALUE".localize())
            }
            moneyTextField.textField.text = Int(moneyTextField.textField.text?.replace(string: ",", replacement: "") ?? "")?.addComma(",")
            break
        default: break
        }
        
        guard !dateInTextField.textField.isEmpty(),
              //              !dateOutTextField.textField.isEmpty(),
              !placeTextField.textField.isEmpty(),
              !diagTextField.textField.isEmpty(),
              !moneyTextField.textField.isEmpty(),
              checkInfoIsFilled()
        else {
            disableSubmitButton()
            return
        }
        enableSubmitButton()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case dateInTextField.textField:
            textFieldIndex = 0
            self.textField = dateInTextField.textField
            self.currentDatePickerView = dateInPickerView
            break
        case dateOutTextField.textField:
            textFieldIndex = 1
            self.textField = dateOutTextField.textField
            self.currentDatePickerView = dateOutPickerView
            break
        case placeTextField.textField:
            textFieldIndex = 2
            self.textField = placeTextField.textField
            break
        case diagTextField.textField:
            textFieldIndex = 3
            self.textField = diagTextField.textField
            break
        case moneyTextField.textField:
            textFieldIndex = 4
            self.textField = moneyTextField.textField
            break
        default:
            break
        }
        
        return true
    }
    
}

// MARK: ProofViewDelegate
extension ProofViewController: ProofViewDelegate {
    func updateListTreatmentPlacesBaoMinh(list: PagedListDataRespone) {
        treatmentPlacesBaoMinh = list.items
        treatmentTableView.reloadData()
    }
    
    func lockUI() {
            
    }
    
    func unlockUI() {
        
    }
    
    func updateUI() {
        
    }
    
    func showError(error: ApiError) {
        switch error {
        case .refresh:
            break
        case .expired:
            logOut()
            queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                self.hideBasePopup()
                self.navigationController?.popToRootViewController(animated: true)
            } handler: {
                
            }
            break
            case .requestTimeout(let error):
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                } handler: {
                    
                }
        default:
            break
        }
    }
    
    func uploadFilesSuccess(files: String) {
        
    }
    
    func createClaimSuccess() {
        
    }
    
    func updateListTreatmentPlaces(list: [CoSoYTeModel]) {
        
        treatmentPlaces = list
    }
}
