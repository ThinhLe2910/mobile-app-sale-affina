//
//  FlexiCategoriesFilterView.swift
//  affina
//
//  Created by Dylan on 19/10/2022.
//

import UIKit

class FlexiCategoriesFilterView: BaseView {
    static let nib = "FlexiCategoriesFilterView"

    @IBOutlet weak var containerView: BaseView!
    
    @IBOutlet weak var headerView: BaseView!
    
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var applyButton: BaseButton!
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    @IBOutlet weak var rangeTextField: TitleTextFieldBase!
    @IBOutlet weak var rangeSlider: RangeSlider!
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    private var maxRangeAmount: Int = 0
    private var lowerRangeAmount: Int = 0
    private let MAX_MONEY: CGFloat = 15000
    private var isLatestVoucher = false
    private var isPopularVoucher = false
    private var isAscPrice = false
    private var isDescPrice = false
    
    var closeCallBack: (([Bool]) -> Void)?
    var changeRangeCallback: ((Int, Int) -> Void)?
    
    private var items: [FilterModel] = [
//        FilterModel(iconName: "ic_new", name: "Sản phẩm mới nhất", isSelected: false),
//        FilterModel(iconName: "ic_hot", name: "Sản phẩm phổ biến", isSelected: false),
        FilterModel(iconName: "ic_increase", name: "PRICE_LOW_TO_HIGH".localize(), isSelected: false),
        FilterModel(iconName: "ic_descrease", name: "PRICE_HIGH_TO_LOW".localize(), isSelected: false)
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(FlexiCategoriesFilterView.nib, owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = .appColor(.blueUltraLighter)
        
        containerView.addTapGestureRecognizer {
            self.endEditing(true)
        }
        
        headerHeightConstraint.constant = UIConstants.Layout.headerHeight
        
        addBlurEffect(headerView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: FlexiFilterTableViewCell.nib, bundle: nil), forCellReuseIdentifier: FlexiFilterTableViewCell.cellId)
        
        rangeSlider.hide()
        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged), for: .valueChanged)
        rangeTextField.textField.disable()
        
        rangeTextField.textField.backgroundColor = .appColor(.blueExtremeLight)
        
        rangeSliderValueChanged()
        
        closeButton.addTapGestureRecognizer {
            UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseInOut, animations: {
                self.frame.origin.x = UIConstants.Layout.screenWidth
            }) { _ in
                self.removeFromSuperview()
            }
        }
        
        applyButton.addTapGestureRecognizer {
            UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseInOut, animations: {
                self.frame.origin.x = UIConstants.Layout.screenWidth
            }) { _ in
                self.removeFromSuperview()
                self.closeCallBack?(self.items.map { $0.isSelected })
            }
        }
    }
    
    func addBlurEffect(_ view: UIView) {
        view.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
    }
    
    @objc private func rangeSliderValueChanged() {
        lowerRangeAmount = Int(MAX_MONEY * rangeSlider.lowerValue)
        maxRangeAmount = Int(MAX_MONEY * rangeSlider.upperValue)
        rangeTextField.textField.text = "\(lowerRangeAmount.addComma()) \("COIN".localize()) - \(maxRangeAmount.addComma()) \("COIN".localize())"
        rangeTextField.textField.disable()
        changeRangeCallback?(lowerRangeAmount, maxRangeAmount)
    }
    
}

extension FlexiCategoriesFilterView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FlexiFilterTableViewCell.cellId, for: indexPath) as? FlexiFilterTableViewCell else { return UITableViewCell() }
        cell.item = items[indexPath.row]
        cell.callBack = { isSelected in
            for i in 0..<self.items.count {
                self.items[i].isSelected = false
            }
            self.items[indexPath.row].isSelected = isSelected
            self.tableView.reloadData()
        }
        return cell
    }
    
}

struct FilterModel {
    let iconName: String
    let name: String
    var isSelected: Bool
}
