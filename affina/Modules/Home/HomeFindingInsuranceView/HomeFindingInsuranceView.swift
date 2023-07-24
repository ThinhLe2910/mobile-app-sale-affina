//
//  HomeFindingInsuranceView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 04/07/2022.
//

import UIKit

protocol HomeFindingInsuranceDelegate: AnyObject {
    func didTapInsuranceList(_ id: String)
    func didTapInsuranceIcon()
}

@IBDesignable
class HomeFindingInsuranceView: UIView {
    
    static let nib = "HomeFindingInsuranceView"
    
    class func instanceFromNib() -> HomeFindingInsuranceView {
        return UINib(nibName: self.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HomeFindingInsuranceView
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var detailButton: BaseButton!
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var descLabel: BaseLabel!
    @IBOutlet weak var chooseLabel: BaseLabel!
    @IBOutlet weak var insuranceIcon: UIImageView!
    
    weak var delegate: HomeFindingInsuranceDelegate?
    
    var isFisrtLoading = true
    
    //    var categories: [String] = ["ALL".localize(), "LIFE_INSURANCE".localize(), "HEALTH".localize(), "NONLIFE_INSURANCE".localize()]
    
    var categories: [ProgramType] = [ProgramType(id: "-1", majorId: "ALL", name: "ALL".localize(), type: -1)] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: CategoryInsuranceCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        detailButton.addTarget(self, action: #selector(didTapDetailButton), for: .touchUpInside)
        
        insuranceIcon.addTapGestureRecognizer {
            self.didTapInsuranceIcon()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTitle), name: NSNotification.Name(Key.changeLocalize.rawValue), object: nil)
        reloadTitle()
    }
    
    @objc private func didTapDetailButton() {
        var isPickedAtLeast = false
        var selectedId = ""
        for i in 0..<categories.count {
            if let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? CategoryInsuranceCollectionViewCell {
                if cell.isPicked {
                    isPickedAtLeast = true
                    selectedId = categories[i].id
                    if selectedId == "-1" {
                        selectedId = categories[1].id
                    }
                    break
                }
            }
        }
        if isPickedAtLeast {
            delegate?.didTapInsuranceList(selectedId)
        }
    }
    
    @objc private func didTapInsuranceIcon() {
        var isPickedAtLeast = false
        for i in 0..<categories.count {
            if let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? CategoryInsuranceCollectionViewCell {
                if cell.isPicked {
                    isPickedAtLeast = true
                    break
                }
            }
        }
        if isPickedAtLeast {
            delegate?.didTapInsuranceIcon()
        }
    }
    
    @objc private func reloadTitle() {
        DispatchQueue.main.async {
            self.categories.removeFirst()
            self.categories.insert(ProgramType(id: "-1", majorId: "ALL", name: "ALL".localize(), type: -1), at: 0)
            self.collectionView.reloadData()
            self.titleLabel.localizeText = "SEARCH_INSURANCE"
            self.descLabel.localizeText = "AND_CHOOSE_RIGHT_PRODUCT"
            self.chooseLabel.localizeText = "CHOOSE_TYPE_OF_INSURANCE"
            self.detailButton.localizeTitle = "BUY_NOW"
        }
    }
}

extension HomeFindingInsuranceView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CategoryInsuranceCollectionViewCell else { return UICollectionViewCell() }
        cell.item = categories[indexPath.row].name
        if indexPath.row == 0 && isFisrtLoading {
            cell.isPicked = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = categories[indexPath.row]
        if item.type == -1 { // Select All
            for i in 1..<categories.count {
                if let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? CategoryInsuranceCollectionViewCell {
                    cell.isPicked = false
                }
            }
        }
        else if item.type != -1, let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CategoryInsuranceCollectionViewCell, cell.isPicked { // Hide border of ALL's cell
            cell.showHideBorder()
        }
        if item.type == -1 || item.type == 0 { // TODO: Now it's available for ALL & HEalth
            for t in 1..<categories.count {
                let cell = collectionView.cellForItem(at: IndexPath(item: t, section: 0)) as? CategoryInsuranceCollectionViewCell
                if t == indexPath.row {
                    cell?.isPicked = true
                } else {
                    cell?.isPicked = false
                }
            }
        }
        
        isFisrtLoading = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let font = UIFont(name: "Raleway-Bold", size: UIConstants.widthConstraint(12)) {
            let fontAttributes = [NSAttributedString.Key.font: font]
            let text = categories[indexPath.row].name
            let size = (text as NSString).size(withAttributes: fontAttributes)
            return .init(width: size.width + 32 + 8, height: 32)
        }
        return .init(width: 100, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
