//
//  InsuranceListViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 09/08/2022.
//

import UIKit

class InsuranceListViewController: BaseViewController {
       
    
    static let nib = "InsuranceListViewController"
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var emptyLabel: BaseLabel!
    var filterModel: FilterInsuranceModel?
    
    var endReached: Bool = false
    var isLoadingMore: Bool = false
    
    var referralCode: String = ""
    
    private var products: [FilterProductModel] = []
    
    private var presenter = InsuranceListViewPresenter()
    
    private var listCoverImageProgram: [ListSetupCoverImageProgram] = LayoutBuilder.shared.getListSetupCoverImageProgram()
    
    private let listLogo: [ListSetupLogo] = LayoutBuilder.shared.getListSetupLogo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("InsuranceListViewController")
        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.backgroundLightGray)
        
//        addBlurStatusBar()
        setupHeaderView()
        
        presenter.setViewDelegate(delegate: self)
        
        tableViewTopConstraint.constant = UIConstants.Layout.headerHeight + 24
        
        if #available(iOS 15.0, *) {
            tableView.isPrefetchingEnabled = false
        } else {
            // Fallback on earlier versions
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: InsuranceListItemTableViewCell.nib, bundle: nil), forCellReuseIdentifier: InsuranceListItemTableViewCell.cellId)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let model = filterModel {
            presenter.filterProduct(filter: model)
        }
    }
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "HEALTH_INSURANCE".localize().capitalized
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
//        rightBaseImage.image = UIImage(named: "ic_filter")?.withRenderingMode(.alwaysTemplate)
//        rightBaseImage.tintColor = .appColor(.black)
//        rightBaseImage.layer.opacity = 0.5
//        rightBaseImage.addTapGestureRecognizer {
//            for controller in self.navigationController!.viewControllers as Array {
//                if controller.isKind(of: InsuranceFilterViewController.self) {
//                    self.navigationController!.popToViewController(controller, animated: true)
//                    break
//                }
//            }
//        }
    }
    
    override func didClickLeftBaseButton() {
        popViewController()
//        navigationController?.popToRootViewController(animated: true)
    }
    
    func loadMoreProducts() {
        isLoadingMore = true
        guard !endReached, !products.isEmpty, var filterModel = filterModel else {
            isLoadingMore = false
            return
        }
        filterModel.id = products[products.count - 1].id
        filterModel.fee = products[products.count - 1].fee
        filterModel.programTypeId = products[products.count - 1].programId
        presenter.filterProduct(filter: filterModel)
    }
    
}

extension InsuranceListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InsuranceListItemTableViewCell.cellId, for: indexPath) as? InsuranceListItemTableViewCell else { return UITableViewCell() }
        cell.item = products[indexPath.row]
        cell.tapMoreCallBack = { [weak self] item in
            guard let self = self else { return }
            let vc = InsuranceDetailViewController()
            vc.filterModel = self.filterModel
            vc.referralCode = self.referralCode
            vc.product = self.products[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        for item in listCoverImageProgram {
            if item.programID == products[indexPath.row].programId {
                if let url = URL(string: API.STATIC_RESOURCE + (item.imageFilter ?? "")) {
                    CacheManager.shared.imageFor(url: url) { image, error in
                        if error != nil {
                            DispatchQueue.main.async {
                                cell.bgImageView.image = UIImage(named: "Card_4")
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            cell.bgImageView.image = image
                        }
                    }
                    break
                }
            }
        }
        
        for item in listLogo {
            if item.companyID == products[indexPath.row].companyId {
                if let url = URL(string: API.STATIC_RESOURCE + (item.logo ?? "")) {
                    CacheManager.shared.imageFor(url: url) { image, error in
                        if error != nil {
                            DispatchQueue.main.async {
                                cell.logoImageView.image = UIImage(named: "pti_logo")
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            cell.logoImageView.image = image
                        }
                    }
                    break
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if products.isEmpty { return UITableView.automaticDimension }
        let item = products[indexPath.row]
        return 521 - 173 + (item.highlight?.htmlToString.heightWithConstrainedWidth(width: self.tableView.contentSize.width - 20 - 40, font: UIConstants.Fonts.appFont(.Medium, 16)) ?? 0) // + 16
    }
}

extension InsuranceListViewController: InsuranceListViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func updateListProduct(list: [FilterProductModel]) {
        if isLoadingMore {
            isLoadingMore = false
            products += list
        }
        else {
            products = list
        }
        tableView.reloadData()
        emptyLabel.isHidden = !products.isEmpty
        tableView.isHidden = products.isEmpty
        endReached = list.isEmpty
    }
    
    func showError() {
        
    }
    
    
}

extension InsuranceListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isLoadingMore && (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            loadMoreProducts()
        }
    }
}
