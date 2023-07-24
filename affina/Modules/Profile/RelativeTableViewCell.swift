//
//  RelativeTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 30/05/2022.
//

import UIKit

class RelativeTableViewCell: BaseTableViewCell<RelativeModel> {
    override var item: RelativeModel? {
        didSet {
            nameLabel.text = item?.name
            emailLabel.text = item?.email
        }
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appColor(.textBlack)
        label.font = UIConstants.Fonts.appFont(.Regular, 16)
        label.text = "Name"
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appColor(.textBlack)
        label.font = UIConstants.Fonts.appFont(.Regular, 16)
        label.text = "Email"
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        emailLabel.text = nil
    }
    
    private func initViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
    }
    
    private func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size8)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size16)
            make.height.equalTo(32)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp_bottom).inset(UIPadding.size16)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size16)
            make.bottom.equalToSuperview().inset(UIPadding.size16)
        }
    }
}
