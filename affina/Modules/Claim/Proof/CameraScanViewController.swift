//
//  CameraScanViewController.swift
//  affina
//
//  Created by Dylan on 16/09/2022.
//

import UIKit
import AVFoundation
import Photos

protocol CameraScanViewDelegate {
    func dismissCameraScan(images: [UIImage], step: Int)
    func cameraScanDidCancel()
}

class CameraScanViewController: BaseViewController {
    // Capture session
    var session: AVCaptureSession?
    // Photo output
    let outputPhoto: AVCapturePhotoOutput = AVCapturePhotoOutput()
    // Video preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    @IBOutlet weak var shutterButton: BaseButton!
    @IBOutlet weak var cancelButton: BaseButton!
    @IBOutlet weak var shutterAgainButton: BaseButton!
    @IBOutlet weak var nextButton: BaseButton!
    @IBOutlet weak var infoButton: BaseButton!
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var photoLibsButon: BaseButton!
    @IBOutlet weak var skipButon: BaseButton!
    @IBOutlet weak var noteLabel: BaseButton!
    
    @IBOutlet weak var headerLabel: BaseLabel!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var cameraView: BaseView!
    @IBOutlet weak var pinnerView: BaseView!
    @IBOutlet weak var optionsView: BaseView! // view for next/cancel/again button
    @IBOutlet weak var actionsView: BaseView! // view for skip/photo lib/shutter button
    
    @IBOutlet weak var leftButtonConstraint: NSLayoutConstraint!
    
    var defaultConstraint: CGFloat = 0
    
    var selectedAssets: [UIImage] = [UIImage]() {
        didSet {
            photoCollectionView.reloadData()
        }
    }
    
    var isCaptureFlow: Bool = false
    var isReviewing: Bool = false
    var isCapturing: Bool = false
    var isLocking: Bool = false
    
    var delegate: CameraScanViewDelegate?
    
    var addImageCallBack:(([UIImage], Int) -> Void)?
    var backCallBack: (() -> Void)?
    
    var cardModel: CardModel?
//    var header: String = ""
    var headers: [String] = []
    var required: [Int] = []
    var step: Int = 0
    
    var claimType: ClaimType = .LABOR_ACCIDENT
    
    var maximumAsset: Int = -1 // Tam thoi handle case unlimited & 1 assets
    
    private var currentImageIndex = 0
    
//    private let noteDict: [String: String] = [
//        "Tường trình tai nạn": "Bạn có thể tải mẫu @TAI_DAY",
//        "Giấy ra viện": "Ví dụ về giấy ra viện",
//        "Giấy chứng nhận phẫu thuật": "Ví dụ về giấy chứng nhận phẫu thuật",
//        "Tường trình tai nạn ": "Hoặc biên bản kết luận sự vụ của công an. Bạn có thể tải mẫu @TAI_DAY",
//        "Chứng từ y tế trước nhập viện": "Ví dụ về chứng từ y tế trước nhập viện",
//        "Chỉ định tái khám sau xuất viện": "Ví dụ về chỉ định tái khám sau xuất viện",
//        "Biên lai khám bệnh": "Ví dụ về biên lai khám bệnh",
//        "Chỉ định và phiếu theo dõi tập vật lý trị liệu": " ",
//        "Phim X Quang": "Bạn cần đưa phim ra ngoài sáng để chụp",
//        "Quá trình điều trị": "Ví dụ về chứng từ về quá trình điều trị",
//        "Bảng chấm công": "Hoặc giấy xác nhận nghỉ của công ty",
//        "Chứng từ lương": "Hợp đồng lao động, quyết định điều chỉnh lương, phiếu lương có xác nhận của công ty",
//        "Hồ sơ khác": ""
//
//    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideHeaderBase()
        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.whiteMain)
        
        if headers.count != 1 {
            self.headerLabel.text = self.headers[self.step].capitalized.capitalized
        }
        else {
            headerLabel.text = headers[0].capitalized.capitalized
        }
        
        defaultConstraint = leftButtonConstraint.constant
        
        cameraView.layer.addSublayer(previewLayer)
        cameraView.bringSubviewToFront(pinnerView)
        pinnerView.show()
        
        checkCameraPermission()
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(UINib(nibName: AttachedImageCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: AttachedImageCollectionViewCell.cellId)
        
        backButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        shutterButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        skipButon.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        photoLibsButon.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        shutterAgainButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
        if maximumAsset == 1 {
            skipButon.hide(isImmediate: true)
        }
        else {
            if self.required[step] == 0 {
                skipButon.show()
            }
            else {
                skipButon.hide(isImmediate: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = cameraView.bounds
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session?.stopRunning()
    }
    
    @objc private func didTapButton(_ sender: BaseButton) {
        switch sender {
            case backButton:
                if !isCaptureFlow && selectedAssets.isEmpty {
                    backCallBack?()
                    if navigationController != nil {
                        popViewController()
                    }
                    else {
                        dismiss(animated: true)
                    }
                    return
                }
                actionsView.show()
                optionsView.hide()
                cancelButton.show()
                pinnerView.show()
                noteLabel.show()
                
                photoCollectionView.hide(isImmediate: true)
                
                previewLayer.isHidden = false
                
                isCaptureFlow = false
                selectedAssets = []
                previewImage.image = nil
                
                if headers.count != 1 {
                    if self.required[step] == 0 {
                        skipButon.show()
                    }
                    else {
                        skipButon.hide(isImmediate: true)
                    }
                }
                else if maximumAsset == 1 {
                    skipButon.hide(isImmediate: true)
                }
                
                setSkipButtonState(true)
                
                leftButtonConstraint.constant = defaultConstraint
                DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                    self.session?.startRunning()
                    DispatchQueue.main.async {
                        self.previewLayer.frame = self.cameraView.bounds
                    }
                }
//                session?.startRunning()
                break
            case infoButton:
                let popup = SampleAccidentReportView()
                popup.setTitleNoteSampleLabel(imageUrl: getProofImage(step: step), title: getProofTitle(step: step), //headers[step],
                                              note: getProofContent(step: step))// noteDict[headers[step]] ?? "")
//                if headers[step] == "Hồ sơ khác" {
//                    popup.setNopeButtonText("Bỏ qua")
//                }
            popup.setNopeButtonText(getProofSkipText(step: step))
                popup.downloadCallback = {
                    let urlString = self.getProofFile(step: self.step)
                    guard let url = URL(string: urlString) else { return }
                    self.lockScreen()
                    FileDownloader.loadFileAsync(url: url) { (path, error) in
                        Logger.Logs(message: "PDF File downloaded to : \(path)")
                        self.unlockScreen()
                    }
                }
                popup.understandCallback = {
                    self.hideBottomSheet(animated: true)
                }
                popup.showUnderstandButton()
                bottomSheet.setContentForBottomSheet(popup)
                setNewBottomSheetHeight(760.height)
                showBottomSheet(animated: true)
                break
            case shutterButton:
                if isCapturing { return }
                isCapturing = true
//                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                outputPhoto.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.actionsView.hide()
                    self.optionsView.show()
                    self.cancelButton.hide()
                    self.pinnerView.hide()
                    self.noteLabel.hide()
                    self.photoCollectionView.hide(isImmediate: true)
                    
                    self.isCaptureFlow = true
                    
                    self.leftButtonConstraint.constant = -UIConstants.Layout.screenWidth/2 + self.shutterAgainButton.frame.width/2 + 24
                })
                break
            case shutterAgainButton:
                isCapturing = false
                
                actionsView.show()
                optionsView.hide()
                cancelButton.show()
                pinnerView.show()
                noteLabel.show()
                photoCollectionView.hide(isImmediate: true)
                
                if !isCaptureFlow && !selectedAssets.isEmpty {
                    selectedAssets.remove(at: currentImageIndex)
                }
                if !selectedAssets.isEmpty {
                    skipButon.show()
                    setSkipButtonState(false)
                }
                else {
                    if headers.count != 1 {
                        if self.required[step] == 0 && maximumAsset != 1 {
                            skipButon.show()
                        }
                        else {
                            skipButon.hide(isImmediate: true)
                        }
                    }
                    else if maximumAsset == 1 {
                        skipButon.hide(isImmediate: true)
                    }
                    
                    setSkipButtonState(true)
                }
                
                isCaptureFlow = false
                previewImage.image = nil
                
                previewLayer.isHidden = false
                
                if !self.selectedAssets.isEmpty {
                    self.photoLibsButon.setImage(self.selectedAssets[self.selectedAssets.count - 1], for: .normal)
                }
                
                leftButtonConstraint.constant = defaultConstraint
                DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                    self.session?.startRunning()
                    DispatchQueue.main.async {
                        self.previewLayer.frame = self.cameraView.bounds
                    }
                }
                break
                // MARK: photoLibsButon
            case photoLibsButon:
                if selectedAssets.isEmpty { return }
                isCaptureFlow = false
                isReviewing = true
                previewLayer.isHidden = true
                currentImageIndex = 0
                previewImage.image = selectedAssets[currentImageIndex]
                
                actionsView.hide()
                optionsView.show()
                cancelButton.show()
                pinnerView.hide()
                noteLabel.hide()
                
                photoCollectionView.show()
                photoCollectionView.reloadData()
                
                break
                // MARK: skipButon
            case skipButon:
                if headers.count != 1 {
                    showSamplePopup()
                }
                else {
                    addImageCallBack?(selectedAssets, step)
                    if navigationController != nil {
                        popViewController()
                    }
                    else {
                        dismiss(animated: true)
                    }
                }
                break
            case cancelButton:
                if selectedAssets.isEmpty { return }
                selectedAssets.remove(at: currentImageIndex)
                currentImageIndex = 0
                photoCollectionView.reloadData()
                if selectedAssets.isEmpty {
                    previewImage.image = nil
                    return
                }
                previewImage.image = selectedAssets[0]
                break
            case nextButton:
                isCapturing = false
                isLocking = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    if self.isCaptureFlow {
                        self.leftButtonConstraint.constant = self.defaultConstraint
                        if !self.isReviewing {
                            if self.previewImage.image != nil {
                                if self.selectedAssets.isEmpty || self.maximumAsset == -1 {
                                    self.selectedAssets.append(self.previewImage.image!)
                                }
                                else {
                                    self.selectedAssets[0] = self.previewImage.image!
                                }
                            }
                            else {
                                self.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: "ERROR_HAPPENED".localize(), okTitle: "TRY_AGAIN".localize(), cancelTitle: "", okHandler: {
                                    self.hideBasePopup()
                                }, handler: {})
                            }
                        }
                        else {
                            if self.previewImage.image != nil {
                                if self.selectedAssets.isEmpty || self.maximumAsset == -1 {
                                    self.selectedAssets.append(self.previewImage.image!)
                                }
                                else {
                                    self.selectedAssets[0] = self.previewImage.image!
                                }
                            }
                        }
                    }
                    
                    self.isReviewing = false
                    self.previewLayer.isHidden = false
                    self.actionsView.show()
                    self.optionsView.hide()
                    self.cancelButton.show()
                    self.pinnerView.show()
                    self.noteLabel.show()
                    self.photoCollectionView.hide(isImmediate: true)
                    
//                    if self.previewImage.image != nil {
//                        self.photoLibsButon.setImage(self.previewImage.image, for: .normal)
//                    }
                    
                    if !self.selectedAssets.isEmpty {
                        self.photoLibsButon.setImage(self.selectedAssets[self.selectedAssets.count - 1], for: .normal)
                    }
                    
                    self.previewImage.image = nil
                    
                    if !self.selectedAssets.isEmpty {
                        self.skipButon.show()
                        self.setSkipButtonState(false)
                    }
                    else {
                        if self.headers.count != 1 {
                            if self.required[self.step] == 0 {
                                self.skipButon.show()
                            }
                            else {
                                self.skipButon.hide(isImmediate: true)
                            }
                        }
                        else if self.maximumAsset == 1 {
                            self.skipButon.hide(isImmediate: true)
                        }
                        self.setSkipButtonState(true)
                    }
                    
                    DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                        self.session?.startRunning()
                        DispatchQueue.main.async {
                            self.previewLayer.frame = self.cameraView.bounds
                        }
                    }
                    
                    self.isLocking = false
                })
                break
            default:
                break
        }
    }
    
    func setSkipButtonState(_ isSkip: Bool) {
        if isSkip {
            self.skipButon.setTitle("SKIP".localize(), for: .normal)
            self.skipButon.borderWidth = 0
            self.photoLibsButon.setImage(UIImage(named: "ic_gallery"), for: .normal)
        }
        else {
            self.skipButon.setTitle("\("SAVE".localize()) (\(self.selectedAssets.count))", for: .normal)
            self.skipButon.borderColor = "grayBorder"
            self.skipButon.borderWidth = 2
            self.skipButon.cornerRadius = 20
        }
    }
    
    // MARK: showSamplePopup
    private func showSamplePopup() {
        if step >= (headers.count - 1) {
            self.addImageCallBack?(self.selectedAssets, self.step + 1)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let popup = SampleAccidentReportView()
        popup.setTitleNoteSampleLabel(imageUrl: getProofImage(step: step+1), title: getProofTitle(step: step+1), // headers[step+1],
                                      note: getProofContent(step: step+1))// noteDict[headers[step+1]] ?? "")
//        if headers[step+1] == "Hồ sơ khác" {
//            popup.setNopeButtonText("Bỏ qua")
//        }
//        else if headers[step+1] == "Giấy chứng nhận phẫu thuật" {
//            if self.claimType == .LABOR_ACCIDENT {
//                popup.setNopeButtonText("Tôi không trải qua phẫu thuật")
//            }
//            else {
//                popup.setNopeButtonText("Tôi không nằm viện")
//            }
//        }
//        else if headers[step+1] == "Phim X Quang" {
//            popup.setNopeButtonText("Tôi không chụp X Quang")
//        }
        popup.setNopeButtonText(getProofSkipText(step: step + 1))
        popup.downloadCallback = {
            let urlString = self.getProofFile(step: self.step + 1)
            guard let url = URL(string: urlString) else { return }
            self.lockScreen()
            FileDownloader.loadFileAsync(url: url) { (path, error) in
                Logger.Logs(message: "PDF File downloaded to : \(path)")
                self.unlockScreen()
            }
        }
        popup.nopeCallback = {
            self.step += 1
            
            self.hideBottomSheet(animated: false)
            self.addImageCallBack?(self.selectedAssets, self.step)
            self.selectedAssets = []
            //            self.navigationController?.popViewController(animated: true)
            self.showSamplePopup()
        }
        popup.uploadCallback = {
            self.step += 1
            
            self.hideBottomSheet(animated: false)
            self.addImageCallBack?(self.selectedAssets, self.step)
            self.headerLabel.text = self.headers[self.step]
            self.selectedAssets = []
            self.isCaptureFlow = false
            if self.required[self.step] == 0 {
                self.skipButon.show()
            }
            else {
                self.skipButon.hide(isImmediate: true)
            }
            
            self.setSkipButtonState(true)
            
            let viewController = PhotoGalleryViewController()
            viewController.delegate = self
            viewController.isCameraAllowed = true
            viewController.header = self.headers[self.step]
            viewController.claimType = self.claimType
            viewController.step = self.step
            viewController.cardModel = self.cardModel
            self.present(viewController, animated: true, completion: nil)
        }
        popup.captureCallback = {
            self.step += 1
            
            self.hideBottomSheet(animated: false)
            self.addImageCallBack?(self.selectedAssets, self.step)
            self.headerLabel.text = self.headers[self.step]
            self.selectedAssets = []
            self.isCaptureFlow = false
            if self.required[self.step] == 0 {
                self.skipButon.show()
            }
            else {
                self.skipButon.hide(isImmediate: true)
            }
            
            self.setSkipButtonState(true)
        }
        
        if self.required[step+1] == 1 {
            popup.showUploadCaptureButtons()
        }
        else {
            popup.showNopeButton()
            popup.showUploadCaptureButtons()
            
        }
        self.bottomSheet.topView.show()
        bottomSheet.setContentForBottomSheet(popup)
        setNewBottomSheetHeight(760.height)
        showBottomSheet(animated: true)
    }
    
    // MARK: Camera
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    guard granted else { return }
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                }
            case .restricted:
                break
            case .denied:
                break
            case .authorized:
                lockScreen()
                setupCamera()
            @unknown default:
                break
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .medium
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(outputPhoto) {
                    session.addOutput(outputPhoto)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                    self.session?.startRunning()
                    DispatchQueue.main.async {
                        self.previewLayer.frame = self.cameraView.bounds
                        
                        self.unlockScreen()
                    }
                }
                self.session = session
                
            }
            catch {
                Logger.Logs(message: error)
                self.unlockScreen()
            }
        }
    }
    
    private func getProofImage(step: Int) -> String {
        var imageString: String =
        "" // UIConstants.Proofs[self.claimTypes[self.index][self.selectedCategory].string]?[self.headers[self.index][self.selectedCategory][step].trimmingWhiteSpaces()] ?? ""
        guard let cardModel = cardModel else { return imageString }
        let list = LayoutBuilder.shared.getListImageClaim()
        for item in list {
            if LayoutBuilder.shared.canUseImageClaim(imageClaim: item, cardModel: cardModel, claimType: claimType) {
                for el in item.listImageClaimDetail ?? [] {
                    if let orderImage = el.orderImage, orderImage == (step + 1) {
                        imageString = API.STATIC_RESOURCE + (el.image ?? "")
                        return imageString
                    }
                }
            }
        }
        return imageString
    }
    
    private func getProofFile(step: Int) -> String {
        var fileString: String = ""
        guard let cardModel = cardModel else { return fileString }
        let list = LayoutBuilder.shared.getListImageClaim()
        for item in list {
            if LayoutBuilder.shared.canUseImageClaim(imageClaim: item, cardModel: cardModel, claimType: claimType) {
                for el in item.listImageClaimDetail ?? [] {
                    if let orderImage = el.orderImage, orderImage == (step + 1) {
                        fileString = API.STATIC_RESOURCE + (el.file ?? "")
                        return fileString
                    }
                }
            }
        }
        return fileString
    }
    
    private func getProofTitle(step: Int) -> String {
        var title: String = "-"
        guard let cardModel = cardModel else { return title }
        let list = LayoutBuilder.shared.getListImageClaim()
        for item in list {
            if LayoutBuilder.shared.canUseImageClaim(imageClaim: item, cardModel: cardModel, claimType: claimType) {
                for el in item.listImageClaimDetail ?? [] {
                    if let orderImage = el.orderImage, orderImage == (step + 1) {
                        title = el.name ?? "-"
                        return title
                    }
                }
            }
        }
        return title
    }
    
    private func getProofContent(step: Int) -> String {
        var content: String = "-"
        guard let cardModel = cardModel else { return content }
        let list = LayoutBuilder.shared.getListImageClaim()
        for item in list {
            if LayoutBuilder.shared.canUseImageClaim(imageClaim: item, cardModel: cardModel, claimType: claimType) {
                for el in item.listImageClaimDetail ?? [] {
                    if let orderImage = el.orderImage, orderImage == (step + 1) {
                        content = el.content ?? "-"
                        return content
                    }
                }
            }
        }
        return content
    }
    
    private func getProofSkipText(step: Int) -> String {
        var text: String = "SKIP".localize()
        guard let cardModel = cardModel else { return text }
        let list = LayoutBuilder.shared.getListImageClaim()
        for item in list {
            if LayoutBuilder.shared.canUseImageClaim(imageClaim: item, cardModel: cardModel, claimType: claimType) {
                for el in item.listImageClaimDetail ?? [] {
                    if let orderImage = el.orderImage, orderImage == (step + 1) {
                        text = el.textButtonSkip ?? "SKIP".localize()
                        return text
                    }
                }
            }
        }
        return text
    }
}

extension CameraScanViewController: AVCapturePhotoCaptureDelegate {
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: "ERROR_HAPPENED".localize(), okTitle: "TRY_AGAIN".localize(), cancelTitle: "", okHandler: {
                self.hideBasePopup()
            }, handler: {})
            Logger.Logs(event: .error, message: error.localizedDescription)
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        
        
        let image = UIImage(data: data)
        
        previewImage.image = image
        session?.stopRunning()
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            self.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: "ERROR_HAPPENED".localize(), okTitle: "TRY_AGAIN".localize(), cancelTitle: "", okHandler: {
                self.hideBasePopup()
            }, handler: {})
            Logger.Logs(event: .error, message: error.localizedDescription)
            return
        }
        
        guard let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) else {
            return
        }
        
        print("image: \(UIImage(data: dataImage)?.size)") // Your Image
        let image = UIImage(data: dataImage)
        previewImage.image = image
        session?.stopRunning()
    }
    
    
}

// MARK: PhotoGalleryDelegate
extension CameraScanViewController: PhotoGalleryDelegate {
    func dismissPhotoGallery(withPHAssets: [PHAsset]) {
        if self.selectedAssets.isEmpty {
            self.selectedAssets = withPHAssets.map({ PhotoManager.getAssetThumbnail(asset: $0) ?? UIImage() })
        }
        else {
            if maximumAsset == -1 {
                self.selectedAssets.append(contentsOf: withPHAssets.map({ PhotoManager.getAssetThumbnail(asset: $0) ?? UIImage() }))
            }
            else {
                self.selectedAssets[0] = withPHAssets.map({ PhotoManager.getAssetThumbnail(asset: $0) ?? UIImage() })[0]
            }
        }
        
        previewLayer.isHidden = !selectedAssets.isEmpty
        if selectedAssets.isEmpty { return }
        previewImage.image = selectedAssets[0]
        
        actionsView.hide()
        optionsView.show()
        cancelButton.show()
        pinnerView.hide()
        noteLabel.hide()
        
        photoCollectionView.show()
        photoCollectionView.reloadData()
        session?.stopRunning()
    }
    
    func photoGalleryDidCancel() {
    }
    
}

// MARK: CollectionViewDelegate
extension CameraScanViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAssets.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachedImageCollectionViewCell.cellId, for: indexPath) as? AttachedImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.row == 0 {
            cell.setImage(nil)
            cell.addImageView.show()
            cell.imageView.hide(isImmediate: true)
        }
        else {
            cell.setImage(selectedAssets[indexPath.row - 1])
            cell.imageView.show()
            cell.addImageView.hide(isImmediate: true)
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
        if indexPath.row == 0 {
            if maximumAsset != -1 && selectedAssets.count >= maximumAsset { return }
            let viewController = PhotoGalleryViewController()
            viewController.delegate = self
            viewController.maximumAsset = maximumAsset
            viewController.header = self.headers[self.step]
            viewController.claimType = self.claimType
            viewController.step = step
            viewController.cardModel = self.cardModel
            self.present(viewController, animated: true, completion: nil)
        }
        else {
            previewImage.image = selectedAssets[indexPath.row - 1]
            currentImageIndex = indexPath.row - 1
        }
    }
}
