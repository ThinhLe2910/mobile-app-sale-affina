//
//  PhotoGalleryViewController.swift
//  affina
//
//  Created by Dylan on 04/10/2022.
//

import UIKit
import Photos

protocol PhotoGalleryDelegate {
    func dismissPhotoGallery(withPHAssets: [PHAsset])
    func photoGalleryDidCancel()
    
}

class PhotoManager {
    static func getAssetThumbnail(asset: PHAsset) -> UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail: UIImage?
        option.isSynchronous = true
        let width = UIConstants.Layout.screenWidth/3 - 2
        manager.requestImage(for: asset, targetSize: CGSize(width: width, height: width), contentMode: .aspectFit, options: option, resultHandler: { (result, info) in
            thumbnail = result
        })
        return thumbnail
    }
    
}

class PhotoGalleryViewController: BaseViewController {
    
    @IBOutlet weak var headerLabel: BaseLabel!
    @IBOutlet weak var infoButton: BaseButton!
    @IBOutlet weak var backButton: BaseButton!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var submitView: BaseView!
    @IBOutlet weak var submitButton: BaseButton!
    
    @IBOutlet weak var heightButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var topButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomButtonConstraint: NSLayoutConstraint!
    
    var delegate: PhotoGalleryDelegate?
    
    var images: [PHAsset] = [PHAsset]()
    var displayedImages: [PHAsset] = [PHAsset]()
    
    var isCameraAllowed: Bool = false
    
    var selectedImages: [Int] = [Int]() {
        didSet {
            var isSeleted = false
            for i in 0..<selectedImages.count {
                let selectedImage = selectedImages[i]
                if selectedImage == 1 {
                    isSeleted = true
                    break
                }
            }
            
            DispatchQueue.main.async {
                if !isSeleted {
                    self.heightButtonConstraint.constant = 0
                    self.bottomButtonConstraint.constant = 0
                    self.topButtonConstraint.constant = 0
                    //                submitView.hide(isImmediate: true)
                }
                else {
                    self.heightButtonConstraint.constant = 56
                    self.bottomButtonConstraint.constant = 24
                    self.topButtonConstraint.constant = 16
                    //                submitView.show()
                }
            }
            
        }
    }
    
    var cardModel: CardModel?
    var step: Int = 0
    var header: String = ""
    var required: Int = 0
    var column: Int = 3
    var maximumAsset: Int = -1 // Tam thoi handle case unlimited & 1 assets
    
    var claimType: ClaimType = .LABOR_ACCIDENT
    
    var CELL_WIDTH: CGFloat {
        return UIConstants.Layout.screenWidth / CGFloat(column) - 2
    }
    
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
        
        view.backgroundColor = .appColor(.blueUltraLighter)
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UINib(nibName: PhotoImageCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: PhotoImageCollectionViewCell.cellId)
        
        backButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
        headerLabel.text = header.capitalized
        
        // Observe photo library changes
        PHPhotoLibrary.shared().register(self)
        
        fetchGalleryData()
    }
    
    private func fetchGalleryData() {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .denied || status == .restricted) {
            return
        } else {
            getPhotos()
        }
    }
    
    private func getPhotos() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if status == .authorized {
                let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                self.images = []
                var temp = [Int]()
                assets.enumerateObjects { object, count, _ in
                    self.images.append(object)
                    temp.append(0)
                }
                
                self.images.reverse()

                self.selectedImages = temp.reversed()
                self.displayedImages = self.images
                
                DispatchQueue.main.async {
                    self.imageCollectionView.reloadData()
                }
            }
            else if #available(iOS 14, *), status == .limited {
                
            }
            else if status == .notDetermined {
                
            }
        }
    }
    
    @objc private func didTapButton(_ sender: BaseButton) {
        switch sender {
            case backButton:
                if navigationController != nil {
                    popViewController()
                }
                else {
                    dismiss(animated: true)
                }
                delegate?.photoGalleryDidCancel()
                break
            case infoButton:
                let popup = SampleAccidentReportView()
                popup.setTitleNoteSampleLabel(imageUrl: getProofImage(), title: header, note: getProofContent()) //noteDict[header] ?? "")
//                if header == "Hồ sơ khác" {
//                    popup.setNopeButtonText("Bỏ qua")
//                }
//                else if header == "Giấy chứng nhận phẫu thuật" {
//                    if self.claimType == .LABOR_ACCIDENT {
//                        popup.setNopeButtonText("Tôi không trải qua phẫu thuật")
//                    }
//                    else {
//                        popup.setNopeButtonText("Tôi không nằm viện")
//                    }
//                }
//                else if header == "Phim X Quang" {
//                    popup.setNopeButtonText("Tôi không chụp X Quang")
//                }
            popup.setNopeButtonText(getProofSkipText())
                popup.downloadCallback = {
                    let urlString = self.getProofFile()
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
            case submitButton:
                var selecteds: [PHAsset] = []
                for i in 0..<selectedImages.count {
                    if selectedImages[i] == 1 {
                        selecteds.append(images[i])
                    }
                }
                
                delegate?.dismissPhotoGallery(withPHAssets: selecteds)
                dismiss(animated: true)
                break
            default: break
        }
    }
    
    private func getProofImage() -> String {
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
    
    private func getProofFile() -> String {
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
    
    private func getProofTitle() -> String {
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
    
    private func getProofContent() -> String {
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
    
    private func getProofSkipText() -> String {
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

// MARK: PHPhotoLibraryChangeObserver
extension PhotoGalleryViewController: PHPhotoLibraryChangeObserver {
    //  get notified when the selected photos changes
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [unowned self] in
//            // Obtain authorization status and update UI accordingly
//            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
//            showUI(for: status)
            self.getPhotos()
        }
    }
    
}

// MARK: UICollectionViewDataSource
extension PhotoGalleryViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedImages.count + (isCameraAllowed ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoImageCollectionViewCell.cellId, for: indexPath) as? PhotoImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.row == 0 && isCameraAllowed {
            cell.imageView.isHidden = true
            cell.cameraImageView.isHidden = false
            cell.setUnChecked()
            return cell
        }
        let index = indexPath.row - (isCameraAllowed ? 1 : 0)
        let asset = displayedImages[index]
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: CGSize(width: CELL_WIDTH, height: CELL_WIDTH), contentMode: .aspectFit, options: nil) { image, _ in
            DispatchQueue.main.async {
                cell.setImage(image)
            }
        }
        cell.imageView.isHidden = false
        if selectedImages[index] == 1 {
            cell.setChecked()
        }
        else {
            cell.setUnChecked()
        }
        return cell
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            Logger.Logs(event: .error, message: error.localizedDescription)
            queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: "CAN_NOT_SAVE_IMAGE_TRY_AGAIN".localize(), okTitle: "", cancelTitle: "") {
                self.hideBasePopup()
            } handler: {
            
            }

        } else {
//            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoImageCollectionViewCell else { return }
        
        if indexPath.row == 0 && isCameraAllowed {
            let vc = CameraScanViewController()
//            vc.maximumAsset = 1
            vc.required = [self.required]
            vc.headers = [header]
            vc.claimType = self.claimType
            vc.addImageCallBack = { [weak self] images, _ in
                guard let self = self else { return }
                for img in images {
                    UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    
                }
            }
            vc.step = step
            vc.cardModel = cardModel
            present(vc, animated: true)
            return
        }
        var count = 0
        for image in selectedImages {
            if image == 1 {
                count += 1
            }
        }
        
        let index = indexPath.row - (isCameraAllowed ? 1 : 0)
        
        if selectedImages[index] == 0 {
            if maximumAsset != -1 && count >= maximumAsset { return }
            
            selectedImages[index] = 1
            cell.setChecked()
        }
        else {
            selectedImages[index] = 0
            cell.setUnChecked()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: CELL_WIDTH, height: CELL_WIDTH)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
}
