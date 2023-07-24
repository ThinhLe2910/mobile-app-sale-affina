//
//  HomeInsuranceCard.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 05/07/2022.
//

import UIKit
import CollectionViewPagingLayout
import SnapKit

class HomeInsuranceCardCell: UICollectionViewCell, StackTransformView {
    
    static let size = CGSize(width: 300.width, height: 190.height)
    static let cellId = "HomeInsuranceCardCell"
    
    var stackOptions = StackTransformViewOptions(
        scaleFactor: 0.10,
        minScale: 0.20,
        maxScale: 1.00,
        maxStackSize: 6,
        spacingFactor: 0.08,
        maxSpacing: nil,
        alphaFactor: 0.25,
        bottomStackAlphaSpeedFactor: 0.90,
        topStackAlphaSpeedFactor: 0.30,
        perspectiveRatio: 0.30,
        shadowEnabled: true,
        shadowColor: .black,
        shadowOpacity: 0.10,
        shadowOffset: .zero,
        shadowRadius: 5.00,
        stackRotateAngel: 0.00,
        popAngle: 0.00,
        popOffsetRatio: .init(width: -1.00, height: 0.00),
        stackPosition: .init(x: 0.75, y: 0.00),
        reverse: false,
        blurEffectEnabled: false,
        maxBlurEffectRadius: 0.1,
        blurEffectStyle: .light
    )
    
    private lazy var cardBg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "Card")
        //        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var card: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 28
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logoText")
        return imageView
    }()
    
    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bảo hiểm tai nạn".uppercased()
        label.font = UIConstants.Fonts.appFont(.Bold, 12)
        label.textColor = UIColor.appColor(.blueExtremeLight)
        return label
    }()
    
    private lazy var dateLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\("DURATION".localize()): 30/07/23"
        label.font = UIConstants.Fonts.appFont(.Medium, 12)
        label.textColor = UIColor.appColor(.blueExtremeLight)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var customerLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Vũ đình khánh phương".uppercased()
        label.font = UIConstants.Fonts.appFont(.Bold, 12)
        label.textColor = UIColor.appColor(.black)
        label.isHidden = true
        return label
    }()
    
    private lazy var numberLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1234 5678 9012 3456"
        //        let screen = UIScreen.main
        //        var newFontSize = screen.bounds.size.height * (17 / 568.0);
        //        if (screen.bounds.size.height < 568) {
        ////            newFontSize = 24 // screen.bounds.size.height * (17 / 480.0);
        //        }
        
        label.font = UIConstants.Fonts.appFont(.Bold, 24, fontName: "DarkerGrotesque")
        label.textColor = UIColor.appColor(.whiteMain)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var label: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\("REMAINING_LIMIT".localize()) (VND)"
        label.font = UIConstants.Fonts.appFont(.Semibold, 12)
        label.textColor = UIColor.appColor(.blueExtremeLight)
        
        return label
    }()
    
    private lazy var moneyLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "400.000.000"
        label.font = UIConstants.Fonts.appFont(.Bold, 14)
        label.textColor = UIColor.appColor(.whiteMain)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var requestButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appColor(.pinkMain)
        button.setTitle("CLAIM_REQUEST".localize().capitalized, for: .normal)
        button.cornerRadius = 16
        button.titleLabel?.font = UIConstants.Fonts.appFont(.Medium, 12)
        return button
    }()
    
    private lazy var infoButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_info")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .appColor(.whiteMain)
        return button
    }()
    
    private var customViews: [UIView] = []
    
    var backgroundAsset: UIColor? = UIColor.appColor(.blue) {
        didSet {
            card.backgroundColor = backgroundAsset
        }
    }
    
    var infoCallBack: (() -> Void)?
    var requestCallBack: (() -> Void)?
    
    var item: CardModel? {
        didSet {
            guard let item = item else { return }
            
            moneyLabel.text = "\(item.maximumAmount.addComma())"
            dateLabel.text = "\("DURATION".localize()): " + "\(item.contractEndDate/1000)".timestampToFormatedDate(format: "dd/MM/yy")
            titleLabel.text = item.programName
            
            numberLabel.text = item.cardNumber // contractObjectIdProvider
            
            
            customerLabel.text = item.peopleName.uppercased()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.isHidden = false
        moneyLabel.isHidden = false
        titleLabel.isHidden = false
        numberLabel.isHidden = false
        dateLabel.isHidden = false
        logoImageView.isHidden = false
        
        label.text = "\("REMAINING_LIMIT".localize()) (VND)"
        requestButton.setTitle("CLAIM_REQUEST".localize().capitalized, for: .normal)
        dateLabel.text = "\("DURATION".localize()): " + "\((item?.contractEndDate ?? 0)/1000)".timestampToFormatedDate(format: "dd/MM/yy")
        
        customViews.forEach { view in
            view.removeFromSuperview()
        }
        customViews = []
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //        numberLabel.sizeToFit()
        //        numberLabel.sizeThatFits(.init(width: HomeInsuranceCardCell.size.width - 32, height: 50))
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
    }
    
    
    func initViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(card)
        card.addSubview(cardBg)
        card.addSubview(logoImageView)
        card.addSubview(titleLabel)
        card.addSubview(dateLabel)
        card.addSubview(customerLabel)
        card.addSubview(numberLabel)
        card.addSubview(label)
        card.addSubview(moneyLabel)
        
        card.addSubview(requestButton)
        card.addSubview(infoButton)
        
        
        card.backgroundColor = .appColor(.blue)
        
        requestButton.addTarget(self, action: #selector(didTapRequestButton), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
    }
    
    func setupConstraints() {
        card.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.greaterThanOrEqualTo(HomeInsuranceCardCell.size.height)
        }
        
        cardBg.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(UIPadding.size16)
            
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size56.height)
            //            make.top.equalTo(logoImageView.snp_bottom).offset(UIPadding.size16)
            make.leading.equalToSuperview().inset(UIPadding.size16)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size56.height)
            //            make.top.equalTo(titleLabel.snp_top)
            make.trailing.equalToSuperview().inset(UIPadding.size16)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(68.height)
            //            make.top.equalTo(titleLabel.snp_bottom).offset(UIPadding.size16)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size16)
        }
        
        label.snp.makeConstraints { make in
            //            make.top.equalTo(numberLabel.snp_bottom).offset(UIPadding.size8)
            make.top.equalToSuperview().inset(108.height)
            make.bottom.equalToSuperview().inset(60.height)
            make.leading.equalToSuperview().inset(UIPadding.size16)//.equalTo(logoImageView.snp_leading)
        }
        
        moneyLabel.snp.makeConstraints { make in
            //            make.top.equalTo(label.snp_top)
            make.top.equalToSuperview().inset(108.height)
            make.bottom.equalToSuperview().inset(64.height)
            make.trailing.equalToSuperview().inset(UIPadding.size16)
        }
        
        requestButton.snp.makeConstraints { make in
            //            make.top.equalTo(label.snp_bottom).offset(UIPadding.size16)
            make.leading.equalTo(logoImageView.snp_leading)
            make.bottom.equalToSuperview().offset(-UIPadding.size16)
            make.width.equalTo(frame.width/2)
            make.height.equalTo(32)
        }
        
        infoButton.snp.makeConstraints { make in
            make.centerY.equalTo(requestButton.snp_centerY)
            make.trailing.equalTo(moneyLabel.snp_trailing)
            make.width.height.equalTo(20)
        }
    }
    
    @objc private func didTapRequestButton() {
        requestCallBack?()
    }
    
    @objc private func didTapInfoButton() {
        infoCallBack?()
    }
    
    func setCardBackground() {
        cardBg.image = UIImage(named: "Card")
        cardBg.isHidden = false
    }
    
    // MARK: updateCardLayout
    func updateCardLayout(_ layouts: [ListSetupCardOrder]) {
        
        if let url = URL(string: API.STATIC_RESOURCE + (layouts[0].background ?? "")) {
            CacheManager.shared.imageFor(url: url) { image, error in
                if error != nil {
                    self.cardBg.image = UIImage(named: "Card")
                    return
                }
                DispatchQueue.main.async {
                    self.cardBg.image = image
                }
            }
        }
        else {
            self.cardBg.image = UIImage(named: "Card")
        }
        
        label.isHidden = true
        moneyLabel.isHidden = true
        titleLabel.isHidden = true
        numberLabel.isHidden = true
        dateLabel.isHidden = true
        logoImageView.isHidden = true
        customerLabel.isHidden = true
        
        customViews.forEach { view in
            view.removeFromSuperview()
        }
        customViews = []
        
        for layout in layouts {
            for field in layout.listCardOrderField ?? [] where layout.orderCard == 1 {
                if field.fieldType == CardFieldTypeEnum.Fixed.rawValue {
                    let label = LayoutBuilder.shared.createLabel(view: card, labelSize: .init(width: CardInsuranceClaimCollectionViewCell.size.width, height: 20), text: field.fieldFixedName, field: field, designSize: HomeInsuranceCardCell.size)
                    customViews.append(label)
                }
                else {
                    if let fieldVariable = field.fieldVariable {
                        let label = LayoutBuilder.shared.getCreatedLabel(fieldVariable, view: card, labelSize: .init(width: HomeInsuranceCardCell.size.width, height: 20), item: item, field: field, designSize: HomeInsuranceCardCell.size)
                        customViews.append(label)
                    }
                }
            }
        }
    }
}
