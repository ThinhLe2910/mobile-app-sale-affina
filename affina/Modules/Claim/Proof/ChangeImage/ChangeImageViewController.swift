//
//  ChangeImageViewController.swift
//  affina
//
//  Created by Dylan on 30/09/2022.
//

import UIKit
import AVFoundation
import Photos

class ChangeImageViewController: BaseViewController {
    @IBOutlet weak var changeButton: BaseButton!
    @IBOutlet weak var nextButton: BaseButton!
    @IBOutlet weak var deleteButton: BaseButton!
    @IBOutlet weak var backButton: BaseButton!
    
    @IBOutlet weak var headerLabel: BaseLabel!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var previewImage: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    
    private var isReplacing: Bool = false
    
    var selectedAssets: [UIImage] = [UIImage]()
    
    var isCaptureFlow: Bool = false {
        didSet {
            if selectedAssets.isEmpty || isCaptureFlow {
                photoCollectionView.hide(isImmediate: true)
            }
            
        }
    }
    
    var addImageCallBack:(([UIImage]) -> Void)?
    
    var cardModel: CardModel?
    
    var headers: [String] = []
    var header: String = ""
    var required: [Int] = []
    var step: Int = 0
    
    var claimType: ClaimType = .LABOR_ACCIDENT
    
    var currentImageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideHeaderBase()
        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.whiteMain)
        
        self.headerLabel.text = header
        
        imagePicker.delegate = self
        
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(UINib(nibName: AttachedImageCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: AttachedImageCollectionViewCell.cellId)
        
        backButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
        if selectedAssets.isEmpty || isCaptureFlow {
            photoCollectionView.hide(isImmediate: true)
            return
        }
        photoCollectionView.show()
        photoCollectionView.reloadData()
        
        if selectedAssets.isEmpty { return }
        previewImage.image = selectedAssets[currentImageIndex]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    @objc private func didTapButton(_ sender: BaseButton) {
        switch sender {
            case backButton:
                popViewController()
                break
            case deleteButton:
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
            case changeButton:
                isReplacing = true
                AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [
                    UIAlertAction(title: "TAKE_PHOTO".localize(), style: .default, handler: { _ in
                        let vc = CameraScanViewController()
                        vc.headers = [self.header]
                        vc.maximumAsset = 1
                        vc.claimType = self.claimType
                        vc.step = self.step
                        vc.cardModel = self.cardModel
                        vc.addImageCallBack = { [weak self] images, _ in
                            self?.isReplacing = false
                            guard let self = self else { return }
                            self.selectedAssets[self.currentImageIndex] = images[0]
                            self.photoCollectionView.reloadData()
                            self.previewImage.image = self.selectedAssets[self.currentImageIndex]
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    }),
                    UIAlertAction(title: "CHOOSE_PHOTOS_FROM_DEVICE".localize(), style: .default, handler: { _ in
                        let viewController = PhotoGalleryViewController() // TLPhotosPickerViewController()
                        viewController.delegate = self
                        viewController.maximumAsset = 1
                        viewController.header = self.header
                        viewController.claimType = self.claimType
                        viewController.step = self.step
                        viewController.cardModel = self.cardModel
                        self.present(viewController, animated: true, completion: nil)
                    }),
                    UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { _ in
                        
                    })], completion: {
                        
                    })
                break
            case nextButton:
                addImageCallBack?(selectedAssets)
                popViewController()
                break
            default:
                break
        }
    }
    
}

// MARK: PhotoGalleryDelegate
extension ChangeImageViewController: PhotoGalleryDelegate {
    func dismissPhotoGallery(withPHAssets: [PHAsset]) {
        if self.selectedAssets.isEmpty {
            self.selectedAssets = withPHAssets.map({ PhotoManager.getAssetThumbnail(asset: $0) ?? UIImage() })
        }
        else {
            if isReplacing {
                self.selectedAssets[currentImageIndex] = withPHAssets.map({ PhotoManager.getAssetThumbnail(asset: $0) ?? UIImage() })[0]
            }
            else {
                self.selectedAssets.append(contentsOf: withPHAssets.map({ PhotoManager.getAssetThumbnail(asset: $0) ?? UIImage() }))
            }
        }
        
        if selectedAssets.isEmpty { return }
        previewImage.image = selectedAssets[0]
        isCaptureFlow = false
        photoCollectionView.reloadData()
        isReplacing = false
    }
    
    func photoGalleryDidCancel() {
    }
    
}

// MARK: CollectionViewDelegate
extension ChangeImageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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
        }
        else {
            cell.setImage(selectedAssets[indexPath.row - 1])
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
            AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [
                UIAlertAction(title: "TAKE_PHOTO".localize(), style: .default, handler: { _ in
//                    self.imagePicker.sourceType = .camera
//                    self.present(self.imagePicker, animated: true, completion: nil)
                    let vc = CameraScanViewController()
                    vc.claimType = self.claimType
                    vc.headers = [self.header]
                    vc.step = self.step
                    vc.cardModel = self.cardModel
                    vc.addImageCallBack = { [weak self] images, _ in
                        self?.selectedAssets.append(contentsOf: images)
                        
                        self?.photoCollectionView.reloadData()
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }),
                UIAlertAction(title: "CHOOSE_PHOTOS_FROM_DEVICE".localize(), style: .default, handler: { _ in
                    let viewController = PhotoGalleryViewController()
                    viewController.delegate = self
                    viewController.header = self.header
                    viewController.claimType = self.claimType
                    viewController.step = self.step
                    viewController.cardModel = self.cardModel
                    self.present(viewController, animated: true, completion: nil)
                }),
                UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { _ in
                    
                })], completion: {
                    
                })
        }
        else {
            currentImageIndex = indexPath.row - 1
            previewImage.image = selectedAssets[indexPath.row - 1]
        }
    }
}

// MARK: UIImagePickerControllerDelegate
extension ChangeImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                
            })], completion: {
                
            })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        previewImage.image = image
        selectedAssets.append(image)
        photoCollectionView.reloadData()
        
        self.imagePicker.allowsEditing = false
        
        if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            image = img
        }
        else if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            image = img
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

