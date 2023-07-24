//
//  CardInsuranceCollectionViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/07/2022.
//

import UIKit
import CollectionViewPagingLayout
import SnapKit

// MARK: CardInsuranceCollectionViewCell
class CardInsuranceCollectionViewCell: UICollectionViewCell, ScaleTransformView {
    
//    static let size = CGSize(width: UIConstants.Layout.screenWidth - 32 * 2, height: 212.height)
    static let size = CGSize(width: 370.width, height: 222.height)
    
    static let cellId = "CardInsuranceCollectionViewCell"
    
    var scaleOptions = ScaleTransformViewOptions(
        minScale: 0.6,
        maxScale: 1.00,
        scaleRatio: 0.3,
        translationRatio: .init(x: 0.75, y: 0.20),
        minTranslationRatio: .init(x: -5.00, y: -5.00),
        maxTranslationRatio: .init(x: 2.00, y: 0.00),
        keepVerticalSpacingEqual: true,
        keepHorizontalSpacingEqual: true,
        scaleCurve: .linear,
        translationCurve: .linear,
        shadowEnabled: true,
        shadowColor: .black,
        shadowOpacity: 0.60,
        shadowRadiusMin: 2.00,
        shadowRadiusMax: 13.00,
        shadowOffsetMin: .init(width: 0.00, height: 2.00),
        shadowOffsetMax: .init(width: 0.00, height: 6.00),
        shadowOpacityMin: 0.10,
        shadowOpacityMax: 0.10,
        blurEffectEnabled: false,
        blurEffectRadiusRatio: 0.40,
        blurEffectStyle: .light,
        rotation3d: nil,
        translation3d: nil
    )

    private lazy var card: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 28
        return view
    }()
    
    lazy var bgCardView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        
        return imageView
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logoText")?.withRenderingMode(.alwaysTemplate)
        return imageView
    }()
    
    private lazy var qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.tintColor = .black
        imageView.image = generateQRCode(from: "AFFINA")
        return imageView
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bảo hiểm tai nạn".uppercased()
        label.font = UIConstants.Fonts.appFont(.Bold, 16)
        label.textColor = UIColor.appColor(.black)
        return label
    }()
    
    private lazy var customerLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Vũ đình khánh phương".uppercased()
        label.font = UIConstants.Fonts.appFont(.Bold, 12)
        label.textColor = UIColor.appColor(.black)
        return label
    }()

    private lazy var dateLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\("DURATION".localize()):\n30/07/23"
        label.font = UIConstants.Fonts.appFont(.Bold, 12)
        label.textColor = UIColor.appColor(.black)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private lazy var numberLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "9087654321"
        label.font = UIConstants.Fonts.appFont(.Bold, 22, fontName: "DarkerGrotesque")
        label.textColor = UIColor.appColor(.black)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
//        label.textAlignment = .center
        return label
    }()

    private lazy var label: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "REMAINING_LIMIT".localize()
        label.font = UIConstants.Fonts.appFont(.Bold, 12)
        label.textColor = UIColor.appColor(.black)

        return label
    }()

    private lazy var moneyLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "400.000.000 VND"
        label.font = UIConstants.Fonts.appFont(.Bold, 12)
        label.textColor = UIColor.appColor(.black)
        return label
    }()

    private lazy var requestButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appColor(.pinkMain)
        button.setTitle("CLAIM_REQUEST".localize().capitalized, for: .normal)
        button.cornerRadius = 16
        button.titleLabel?.font = UIConstants.Fonts.appFont(.Regular, 12)
        return button
    }()

    private lazy var editButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_contract")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .appColor(.black)
        return button
    }()

    var backgroundAsset: UIColor? = UIColor.appColor(.blue) {
        didSet {
            card.backgroundColor = UIColor(hex: "#F7E5FF") // backgroundAsset
        }
    }
    
    var tintColorAsset: UIColor? = UIColor.appColor(.black) {
        didSet {
            logoImageView.tintColor = tintColorAsset
            customerLabel.textColor = tintColorAsset
            label.textColor = tintColorAsset
            numberLabel.textColor = tintColorAsset
            moneyLabel.textColor = tintColorAsset
            dateLabel.textColor = tintColorAsset
            titleLabel.textColor = tintColorAsset
        }
    }
    
    var editCallBack: (() -> Void)?
    var requestCallBack: (() -> Void)?
    
    var xPadding: CGFloat = 32 {
        didSet {
            card.snp.updateConstraints { make in
                make.leading.trailing.equalToSuperview().inset(xPadding)
            }
        }
    }
    
    private var customViews: [UIView] = []
    var item: CardModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            titleLabel.text = item.programName
            dateLabel.text = "\("DURATION".localize()):\n" + "\(item.contractEndDate/1000)".timestampToFormatedDate(format: "dd/MM/yy")
            moneyLabel.text = "\(item.maximumAmount.addComma()) VND"
            customerLabel.text = item.peopleName.uppercased()
            numberLabel.text = item.cardNumber // contractObjectIdProvider
            
            numberLabel.sizeToFit()
            
            DispatchQueue.main.async {
                var textHeight = (item.cardNumber ?? "").uppercased().heightWithConstrainedWidth(width: self.numberLabel.frame.width, font: self.numberLabel.font)
                textHeight = textHeight >= 72 ? 72 : textHeight
                self.customerLabel.snp.updateConstraints { make in
                    make.top.equalToSuperview().inset(88 + textHeight - 36)
                }
                self.dateLabel.snp.updateConstraints { make in
                    make.top.equalToSuperview().inset(108 + textHeight - 36)
                }
                self.label.snp.updateConstraints { make in
                    make.top.equalToSuperview().inset(108 + textHeight - 36)
                }
                self.moneyLabel.snp.updateConstraints { make in
                    make.top.equalToSuperview().inset(124 + textHeight - 36)
                }
                
                self.qrImageView.image = self.generateQRCode(from: item.cardNumber ?? "AFFINA")
            }
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
        bgCardView.image = nil
        customerLabel.isHidden = false
        label.isHidden = false
        moneyLabel.isHidden = false
        titleLabel.isHidden = false
        numberLabel.isHidden = false
        dateLabel.isHidden = false
        logoImageView.isHidden = false
        
        customViews.forEach { view in
            view.removeFromSuperview()
        }
        customViews = []
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
    }
    
    func initViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(card)
        
        card.addSubview(bgCardView)
        
        card.addSubview(requestButton)
        card.addSubview(editButton)
        
        card.addSubview(logoImageView)
        card.addSubview(qrImageView)
        
        card.addSubview(titleLabel)
        card.addSubview(dateLabel)
        card.addSubview(numberLabel)
        card.addSubview(customerLabel)
        card.addSubview(label)
        card.addSubview(moneyLabel)

        
        card.backgroundColor = .appColor(.blue)
        tintColorAsset = .appColor(.black)
        
        requestButton.addTarget(self, action: #selector(didTapRequestButton), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
    }

    func setupConstraints() {
        card.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
//            make.width.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview().inset(xPadding)
        }

        bgCardView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size24)
            make.trailing.equalToSuperview().inset(UIPadding.size8)
            make.height.equalTo(12)
        }

        qrImageView.snp.makeConstraints { make in
//            make.top.equalTo(logoImageView.snp_bottom).offset(UIPadding.size16)
            make.top.equalToSuperview().inset(12 + 24 + UIPadding.size16)
            make.trailing.equalToSuperview().inset(UIPadding.size8)
            make.width.height.equalTo(96.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size24)
//            make.centerY.equalTo(logoImageView.snp_centerY)
            make.leading.equalToSuperview().offset(UIPadding.size16)
            make.trailing.equalToSuperview().inset(96.height + 8 + 8)
//            make.trailing.equalTo(qrImageView.snp_leading).offset(UIPadding.size8)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size48)
//            make.top.equalTo(titleLabel.snp_bottom).offset(UIPadding.size8)
            make.leading.equalToSuperview().inset(UIPadding.size16)
            make.trailing.equalToSuperview().inset(96.height + 8 + 8)
//            make.trailing.equalTo(qrImageView.snp_leading).offset(-UIPadding.size8)
        }
        
        customerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(88)
//            make.top.equalTo(numberLabel.snp_bottom)///.offset(UIPadding.size8)
            make.leading.equalToSuperview().inset(UIPadding.size16)
            make.trailing.equalToSuperview().inset(96.height + 8 + 16)
//            make.trailing.equalTo(qrImageView.snp_leading).offset(UIPadding.size8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(108.height)
//            make.top.equalTo(customerLabel.snp_bottom).offset(UIPadding.size8)
            make.leading.equalToSuperview().inset(144)
//            make.leading.equalTo(moneyLabel.snp_trailing).offset(UIPadding.size8)
            make.trailing.equalTo(qrImageView.snp_leading).offset(-UIPadding.size8)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(108.height)
//            make.top.equalTo(customerLabel.snp_bottom).offset(UIPadding.size8)
            make.leading.equalToSuperview().inset(UIPadding.size16)
//            make.leading.equalTo(customerLabel.snp_leading)
        }
        
        moneyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(124)
//            make.top.equalTo(label.snp_bottom)
//            make.leading.equalTo(label.snp_leading)
            make.leading.equalToSuperview().inset(UIPadding.size16)
        }
        
        requestButton.snp.makeConstraints { make in
//            make.top.equalTo(moneyLabel.snp_bottom).offset(UIPadding.size16)
            make.leading.equalTo(customerLabel.snp_leading)
            make.bottom.equalToSuperview().offset(-UIPadding.size16)
            make.width.equalTo(frame.width/2)
            make.height.equalTo(32)
        }
        
        editButton.snp.makeConstraints { make in
            make.centerY.equalTo(requestButton.snp_centerY)
            make.trailing.equalToSuperview().offset(-UIPadding.size16)
            make.width.height.equalTo(20)
        }
        
    }
    
    @objc private func didTapRequestButton() {
        requestCallBack?()
    }
    
    @objc private func didTapEditButton() {
        editCallBack?()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setDefaults()
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                let colorParameters = [
                    "inputColor0": CIColor(color: UIColor.black), // Foreground
                    "inputColor1": CIColor(color: UIColor.clear) // Background
                ]
                let colored = output.applyingFilter("CIFalseColor", parameters: colorParameters)

                return UIImage(ciImage: colored)
            }
        }

        return nil
    }
//    
//    //forces the system to do one layout pass
//    var isHeightCalculated: Bool = false
//
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        //Exhibit A - We need to cache our calculation to prevent a crash.
//        if !isHeightCalculated {
//            setNeedsLayout()
//            layoutIfNeeded()
//            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//            var newFrame = layoutAttributes.frame
//            newFrame.size.width = CGFloat(ceilf(Float(size.width)))
//            layoutAttributes.frame = newFrame
//            isHeightCalculated = true
//        }
//        return layoutAttributes
//    }
    
    // MARK: updateCardLayout
    func updateCardLayout(_ layouts: [ListSetupCardOrder]) {
        
        if let url = URL(string: API.STATIC_RESOURCE + (layouts[0].background ?? "")) {
            CacheManager.shared.imageFor(url: url) { image, error in
                if error != nil {
                    DispatchQueue.main.async {
                        self.bgCardView.image = nil
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.bgCardView.image = image
                }
            }
        }
        else {
            self.bgCardView.image = nil
        }
        
        label.isHidden = true
        moneyLabel.isHidden = true
        titleLabel.isHidden = true
        numberLabel.isHidden = true
        customerLabel.isHidden = true
        qrImageView.isHidden = true
        dateLabel.isHidden = true
        logoImageView.isHidden = true
        
        customViews.forEach { view in
            view.removeFromSuperview()
        }
        customViews = []
        
        for layout in layouts {
            for field in layout.listCardOrderField ?? [] where layout.orderCard == 1 {
                if field.fieldType == CardFieldTypeEnum.Fixed.rawValue {
//                    let label = BaseLabel(frame: .init(x: 0, y: 0, width: CardInsuranceClaimCollectionViewCell.size.width, height: 20))
//                    //                        label.translatesAutoresizingMaskIntoConstraints = false
//                    card.addSubview(label)
//                    label.text = field.fieldFixedName
//                    updateViewPos(view: label, field: field)
//                    let label = LayoutBuilder.shared.createLabel(view: card, labelSize: .init(width: CardInsuranceClaimCollectionViewCell.size.width, height: 20), text: field.fieldFixedName, field: field, designSize: HomeInsuranceCardCell.size)
                    let label = LayoutBuilder.shared.createLabel(view: card, labelSize: .init(width: frame.width, height: 30), text: field.fieldFixedName, field: field, designSize: CardInsuranceCollectionViewCell.size)
                    customViews.append(label)
                }
                else {
                    if let fieldVariable = field.fieldVariable {
                        let label = LayoutBuilder.shared.getCreatedLabel(fieldVariable, view: card, labelSize: .init(width: frame.width, height: 30), item: item, field: field, designSize: CardInsuranceCollectionViewCell.size)
                        customViews.append(label)
                    }
                }
            }
        }
    }
}
