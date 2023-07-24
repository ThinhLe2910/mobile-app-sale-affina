//
//  VoucherReviewViewController.swift
//  affina
//
//  Created by Dylan on 20/10/2022.
//

import UIKit
import YPImagePicker

class VoucherReviewViewController: BaseViewController {

    @IBOutlet weak var contentView: BaseView!
    
    @IBOutlet weak var reviewTextField: UITextField!
    
    @IBOutlet weak var ratedStarsView: RatedStarsView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: BaseView!
    
    @IBOutlet weak var bottomBottomConstraint: NSLayoutConstraint!
    
    private let imagePicker = UIImagePickerController()
    
    private var images: [UIImage] = []
    
    private let presenter = VoucherReviewViewPresenter()
    
    var voucherId: String = ""
    var providerId: String = ""
    var code: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeaderView()
        containerBaseView.hide()
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        ratedStarsView.starType = 1
        ratedStarsView.allowsRating = true
        
        addBlurEffect(bottomView)
        
        let sendView = UIView(frame: .init(x: 0, y: 0, width: 40, height: 48))
        let sendIcon = UIImageView(image: UIImage(named: "ic_send"))
        sendView.addSubview(sendIcon)
        sendIcon.frame = .init(x: 0, y: 12, width: 24, height: 24)
        reviewTextField.rightViewMode = .always
        reviewTextField.rightView = sendView
        
        sendView.addTapGestureRecognizer {
            self.didTapSendComment()
        }
        
        reviewTextField.delegate = self
        reviewTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        //        emptyLabel.hide(isImmediate: true)
        
        contentView.addTapGestureRecognizer {
            self.view.endEditing(true)
        }

        presenter.delegate = self
        imagePicker.delegate = self
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UINib(nibName: ReviewAttachImageCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: ReviewAttachImageCollectionViewCell.cellId)
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        bottomBottomConstraint.constant = 0
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomBottomConstraint.constant = keyboardSize.height - 24
//            let yOffset = (commentsTableView?.convert(commentsTableView?.bounds.origin ?? .zero, to: contentView).y ?? 0)
//            scrollView.setContentOffset(.init(x: 0, y: yOffset - keyboardSize.height), animated: true)
        }
    }
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "MY_VOUCHERS".capitalized.localize()
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        rightBaseImage.image = UIImage(named: "ic_camera_bold")
        rightBaseImage.addTapGestureRecognizer {
            AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [
                UIAlertAction(title: "TAKE_PHOTO".localize(), style: .default, handler: { _ in
                    self.imagePicker.sourceType = .camera
                    self.present(self.imagePicker, animated: true, completion: nil)
                }),
                UIAlertAction(title: "CHOOSE_PHOTOS_FROM_DEVICE".localize(), style: .default, handler: { _ in
//                    self.imagePicker.sourceType = .photoLibrary
//                    self.present(self.imagePicker, animated: true, completion: nil)
                    var config = YPImagePickerConfiguration()
                    config.library.maxNumberOfItems = 1000
                    config.showsPhotoFilters = false
                    config.showsVideoTrimmer = false
                    config.startOnScreen = YPPickerScreen.library
                    config.screens = [.library]
                    config.showsCrop = .none
                    config.library.onlySquare = true
                    config.library.defaultMultipleSelection = true
                    config.library.itemOverlayType = .grid
                    config.library.mediaType = .photo
                    let picker = YPImagePicker(configuration: config)
                    picker.didFinishPicking { [weak self, unowned picker] items, cancelled in
                        self?.images = []
                        for item in items {
                            switch item {
                                case .photo(let photo):
                                    self?.images.append(photo.originalImage)
                                case .video(let video):
                                    print(video)
                            }
                        }
                        self?.imageCollectionView.reloadData()
                        picker.dismiss(animated: true, completion: nil)
                    }
                    self.present(picker, animated: true)
                }),
                UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { _ in

                })], completion: {
                    
                })
        }
        
    }

    
    private func didTapSendComment() {
        guard let comment = reviewTextField.text, !comment.isEmpty, ratedStarsView.ratedStar != 0 else { return }
        
        presenter.ratingVoucher(voucherId: voucherId, providerId: providerId, code: code, point: Int(ratedStarsView.ratedStar), comment: comment, images: images)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
    }
    
}

// MARK: VoucherReviewViewDelegate
extension VoucherReviewViewController: VoucherReviewViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func ratingVoucherSuccess() {
        didClickLeftBaseButton()
    }
    
    func handleRatingError() {
        self.showErrorPopup(error: .custom(NSError(domain:"", code:401, userInfo:[ NSLocalizedDescriptionKey: "ERROR_RATING_DES".localize()]) as Error))
    }
}

// MARK:  UICollectionViewDataSource + UICollectionViewDelegateFlowLayout
extension VoucherReviewViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewAttachImageCollectionViewCell.cellId, for: indexPath) as? ReviewAttachImageCollectionViewCell else { return UICollectionViewCell() }
        cell.imageView.image = images[indexPath.row]
        cell.deleteCallBack = {
            self.images.remove(at: indexPath.row)
            self.imageCollectionView.reloadData()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}

// MARK: UIImagePickerControllerDelegate
extension VoucherReviewViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

