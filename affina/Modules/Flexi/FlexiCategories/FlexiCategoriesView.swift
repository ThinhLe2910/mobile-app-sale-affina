//
//  FlexiCategoriesView.swift
//  affina
//
//  Created by Dylan on 19/10/2022.
//

import UIKit

class FlexiCategoriesView: BaseCollectionView<PointCategoryCollectionViewCell, VoucherCategoryModel> {
    //    var callBack: ((HomeFeaturedProduct) -> Void)?
    var selectedCategory: Int = 0
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PointCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.item = items[indexPath.row]
        if indexPath.row == selectedCategory {
            cell.setColors(bgColor: "secondaryViolet", iconColor: "whiteMain", textColor: "black")
            cell.iconView.layer.masksToBounds = true
        }
        else {
            cell.iconView.layer.masksToBounds = false
            cell.setColors(bgColor: "whiteMain", iconColor: "secondaryViolet", textColor: "black")
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PointCategoryCollectionViewCell else { return }
        
        for i in 0..<items.count {
            if i != indexPath.row, let cell2 = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? PointCategoryCollectionViewCell {
                cell2.iconView.layer.masksToBounds = false
                cell2.setColors(bgColor: "whiteMain", iconColor: "secondaryViolet", textColor: "black")
            }
        }
        selectedCategory = indexPath.row
        cell.setColors(bgColor: "secondaryViolet", iconColor: "whiteMain", textColor: "black")
        cell.iconView.layer.masksToBounds = true
        
        super.collectionView(collectionView, didSelectItemAt: indexPath)
    }
}
