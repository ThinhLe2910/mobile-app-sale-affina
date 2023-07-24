//
//  ContractCompensationHistoryTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 08/08/2022.
//

import UIKit

struct ContractCompensationHistoryModel {
    let hospitalName: String
    let diagnostic: String
    let price: CGFloat
    let date: String
    let type: String
    let status: Int // 0: moi tao, 1. da duyet
}

class ContractCompensationHistoryTableViewCell: UITableViewCell {
    
    static let nib = "ContractCompensationHistoryTableViewCell"
    static let cellId = "ContractCompensationHistoryTableViewCell"
    
    @IBOutlet weak var dateLabel: BaseLabel!
    @IBOutlet weak var hospitalLabel: BaseLabel!
    @IBOutlet weak var diagnosticLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var stateButton: BaseButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var item: ContractCompensationHistoryModel? {
        didSet {
            guard let item = item else { return }
            
            hospitalLabel.text = item.hospitalName
            dateLabel.text = item.date
            
            let priceText = "\(Int(item.price).addComma()) "
            let currencyText = "VND"
            let attrs2 = [
                NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 20)
            ] as [NSAttributedString.Key : Any]
            let attributedString2 = NSMutableAttributedString(string: priceText, attributes: attrs2)
            let normalString2 = NSMutableAttributedString(string: currencyText)
            attributedString2.append(normalString2)
            priceLabel.attributedText = attributedString2
            
            let normalText = item.diagnostic
            let boldText = "\("DIAGNOSE".localize()): "
            let attrs = [NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 14)] as [NSAttributedString.Key : Any]
            let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
            let normalString = NSMutableAttributedString(string: normalText)
            attributedString.append(normalString)
            diagnosticLabel.text = item.diagnostic
            diagnosticLabel.attributedText = attributedString
            
            if item.status == 0 {
                stateButton.setTitle("NEWLY_CREATED".localize(), for: .normal)
                stateButton.setImage(UIImage(named: "ic_new_state"), for: .normal)
                priceLabel.textColor = .appColor(.blueLighter)
            }
            else if item.status == 2 {
                stateButton.setTitle("DECLINE".localize(), for: .normal)
                stateButton.setImage(UIImage(named: "ic_new_state")?.withRenderingMode(.alwaysTemplate), for: .normal)
                stateButton.tintColor = .appColor(.grayLight)
                priceLabel.textColor = .appColor(.blueLighter)
            }
            else {
                stateButton.setTitle("APPROVED".localize(), for: .normal)
                stateButton.setImage(UIImage(named: "ic_processing_state"), for: .normal)
                priceLabel.textColor = .black
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: ContractCompensationHistoryImageCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: ContractCompensationHistoryImageCollectionViewCell.cellId)
    }
    
}

extension ContractCompensationHistoryTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContractCompensationHistoryImageCollectionViewCell.cellId, for: indexPath) as? ContractCompensationHistoryImageCollectionViewCell else { return UICollectionViewCell() }
        cell.imageView.image = UIImage(named: "sign_\(indexPath.row)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 48, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIPadding.size8/2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
//        let tag = indexPath.row + 1
//        let image = UIImage(named: "sign_\(indexPath.row)")
//        let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: tag)
//        let fullScreenImageViewController = FullScreenImageViewController(image: image!, tag: tag)
//        fullScreenImageViewController.modalPresentationStyle = .custom
//        fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
//        
//        UIApplication.topViewController()?.present(fullScreenImageViewController, animated: true)
//        self.fullScreenTransitionManager = fullScreenTransitionManager
    }
}
