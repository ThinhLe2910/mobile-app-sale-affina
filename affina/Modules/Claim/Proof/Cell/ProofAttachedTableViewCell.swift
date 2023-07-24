//
//  ProofAttachedTableViewCell.swift
//  affina
//
//  Created by Dylan on 21/09/2022.
//

import UIKit
import Photos

class ProofAttachedTableViewCell: UITableViewCell {

    static let nib = "ProofAttachedTableViewCell"
    static let cellId = "ProofAttachedTableViewCell"
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: BaseLabel!
    
    private let imagePicker = UIImagePickerController()
    
    var presentCallBack: ((UIViewController) -> Void)?
    var addImageCallBack: (([UIImage]) -> Void)?
    var changeImageCallBack: ((Int) -> Void)?
    var images: [UIImage] = [UIImage()] {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    
    var step: Int = -1
    var cardModel: CardModel?
    
    var claimType: ClaimType = .LABOR_ACCIDENT
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        imagePicker.delegate = self
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UINib(nibName: AttachedImageCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: AttachedImageCollectionViewCell.cellId)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageCollectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension ProofAttachedTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachedImageCollectionViewCell.cellId, for: indexPath) as? AttachedImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.hideMoreText()
        if indexPath.row == 0 {
//            cell.imageView.image = nil
            cell.setImage(nil)
            return cell
        }
        cell.setImage(images[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 72, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            changeImageCallBack?(indexPath.row)
            return
        }
        
        pickID()
    }
    
    @objc func pickID() {
        AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [
            UIAlertAction(title: "TAKE_PHOTO".localize(), style: .default, handler: { _ in
                let vc = CameraScanViewController()
                vc.claimType = self.claimType
                vc.step = self.step
                vc.cardModel = self.cardModel
                vc.headers = [self.titleLabel.text?.components(separatedBy: " (")[0] ?? ""]
                vc.addImageCallBack = { [weak self] images, _ in
                    self?.images.append(contentsOf: images)
                    self?.addImageCallBack?(self?.images ?? [])
                }
                self.presentCallBack?(vc)
            }),
            UIAlertAction(title: "CHOOSE_PHOTOS_FROM_DEVICE".localize(), style: .default, handler: { _ in
                let vc = PhotoGalleryViewController()
                vc.delegate = self
                vc.header = self.titleLabel.text?.components(separatedBy: " (")[0] ?? ""
                vc.claimType = self.claimType
                vc.step = self.step
                vc.cardModel = self.cardModel
                self.presentCallBack?(vc)
            }),
            UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { _ in
                
            })], completion: {
                
            })
    }
}

// MARK: UIImagePickerControllerDelegate
extension ProofAttachedTableViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        images.append(image)
        imageCollectionView.reloadData()
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

extension ProofAttachedTableViewCell: PhotoGalleryDelegate {
    func dismissPhotoGallery(withPHAssets: [PHAsset]) {
        self.images.append(contentsOf: withPHAssets.map({ PhotoManager.getAssetThumbnail(asset: $0) ?? UIImage() }))
        addImageCallBack?(images)
        
        imageCollectionView.reloadData()
    }
    
    func photoGalleryDidCancel() {
        
    }
    
}
