//
//  InsuranceFilterViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 09/08/2022.
//

import UIKit

class InsuranceFilterViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: BaseView!
    @IBOutlet weak var backButton: BaseButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var healthView: InsuranceHealthView!
    
    @IBOutlet weak var nextButton: BaseButton!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    private var presenter: InsuranceFilterViewPresenter = InsuranceFilterViewPresenter()
    private var insuranceTypes: [ProgramType] = []
    
    private var filterModel: FilterInsuranceModel = FilterInsuranceModel(id: nil, fee: nil, limit: 10, programTypeId: "", dob: 0, fromAmount: 0, toAmount: 20000000, listProviderId: nil, companyId: "200001000")
    
    private var textFieldIndex = -1
    private var textField: TextFieldAnimBase!
    
    private var referralCode: String = ""
    
    var selectedTypeId: String = ""
    
    var isOpenedDirectly: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideHeaderBase()
        containerBaseView.hide()
        
        addBlurStatusBar()
        view.backgroundColor = .appColor(.blueUltraLighter)
        
        presenter.setViewDelegate(delegate: self)
        
        healthView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: InsuranceTypeCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: InsuranceTypeCollectionViewCell.cellId)
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        
        presenter.getListInsuranceType()
//        presenter.getListCompanyProvider(search: "")
        
        disableSubmitButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.healthView.rangeSlider.updateLayerFrames()
            self.healthView.rangeSlider.show()
        }
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollViewBottomConstraint.constant = keyboardSize.height
            let yOffset = contentView.convert(textField?.frame.origin ?? .zero, from: textField).y

            scrollView.setContentOffset(.init(x: 0, y: yOffset - keyboardSize.height + 74), animated: true)
        }
    }

    override func keyboardWillHide(notification: NSNotification) {
        scrollViewBottomConstraint.constant = 0
    }

    @objc private func didTapBackButton() {
        if !isOpenedDirectly {
            navigationController?.popViewController(animated: true)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func didTapInsuranceType(_ button: BaseButton) {
        
    }
    
    @objc private func didTapNextButton() {
        Logger.Logs(message: filterModel)
        if filterModel.dob == 0 { return }
        
        let vc = InsuranceListViewController(nibName: InsuranceListViewController.nib, bundle: nil)
        vc.filterModel = filterModel
        vc.referralCode = referralCode
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func enableSubmitButton() {
        nextButton.isUserInteractionEnabled = true
        nextButton.backgroundColor = .appColor(.pinkMain)
        nextButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        nextButton.dropShadow(color: UIColor.appColor(.pinkLong) ?? UIColor(hex: "FF52DB"), opacity: 0.25, offset: .init(width: 0, height: 8), radius: 16, scale: true)
    }

    private func disableSubmitButton() {
        nextButton.isUserInteractionEnabled = false
        nextButton.backgroundColor = .appColor(.pinkUltraLighter)
        nextButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        nextButton.clearShadow()
    }
}

extension InsuranceFilterViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return insuranceTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InsuranceTypeCollectionViewCell.cellId, for: indexPath) as? InsuranceTypeCollectionViewCell else { return UICollectionViewCell() }
        cell.nameLabel.text = insuranceTypes[indexPath.row].name
        if selectedTypeId == insuranceTypes[indexPath.row].id {
//        if insuranceTypes[indexPath.row].type == 0 && indexPath.row == 0 {
            cell.setSelected()
            filterModel.programTypeId = insuranceTypes[indexPath.row].id
        }
        else {
            cell.setUnSelected()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InsuranceTypeCollectionViewCell else { return }
        if insuranceTypes[indexPath.row].type == 0 {
            filterModel.programTypeId = insuranceTypes[indexPath.row].id
            if selectedTypeId != filterModel.programTypeId {
                healthView.companyProviders = []
                healthView.hideEmptyLabel()
            }
            selectedTypeId = filterModel.programTypeId
            for i in 0..<insuranceTypes.count {
                cell.setSelected()
                if i != indexPath.row {
                    if let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? InsuranceTypeCollectionViewCell { cell.setUnSelected() }
                }
            }
        }
        else {
            cell.setUnSelected()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: insuranceTypes[indexPath.row].name.widthWithConstrainedHeight(height: 48, font: UIConstants.Fonts.appFont(.Bold, 16)) + 40, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIPadding.size8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return UIPadding.size8
    }
}

extension InsuranceFilterViewController: InsuranceFilterViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func updateListCompanyProvider(list: [CompanyProvider]) {
        healthView.companyProviders = list
    }
    
    func updateListProgramType(list: [ProgramType]) {
        insuranceTypes = list.filter({ $0.type == 0 })
        if insuranceTypes.isEmpty {
//            queueBasePopup(icon: UIImage(named: "ic_warning"), title: "Đã có lỗi xảy ra.", desc: " Vui lòng thử lại sau!", okTitle: "GOT_IT", cancelTitle: "") {
//                self.dismiss(animated: true, completion: nil)
//            } handler: {
//
//            }
            return
        }
        if selectedTypeId == "" {
            if list.filter({ $0.type == 0 }).isEmpty { return }
            filterModel.programTypeId = list.filter({ $0.type == 0 })[0].id
            selectedTypeId = filterModel.programTypeId
        }
        collectionView.reloadData()
    }
    
    func showError() {
        
    }
    
}

extension InsuranceFilterViewController: InsuranceHealthViewDelegate {
    func selectTextField(index: Int, textField: TextFieldAnimBase) {
        textFieldIndex = index
        self.textField = textField
    }
    
    func updateGenderModel(gender: Int) {
        filterModel.gender = gender
    }
    
    func updateDobModel(dob: Double) {
        filterModel.dob = dob
    }
    
    func updateRangeModel(from: Int, to: Int) {
        filterModel.fromAmount = from
        filterModel.toAmount = to
    }
    
    func updateProviderModel(list: [CompanyProvider]) {
        filterModel.listProviderId = list.isEmpty ? nil : list.map({ $0.id })
    }
    
    func updateReferalModel(referal: String) {
//        filterModel.companyId = referal
        referralCode = referal
    }
    
    func searchCompanyProvider(name: String) {
        let providers = healthView.companyProviders
        let createdAt: Double = -1 // providers.isEmpty ? -1 : (providers[providers.count - 1].createdAt ?? -1)
        let id = "" // providers.isEmpty ? "" : providers[providers.count - 1].id
        presenter.getListCompanyProvider(search: name, id: id, programTypeId: selectedTypeId, createdAt: createdAt)
    }
    
    func enableNextButton() {
        enableSubmitButton()
    }
    
    func disableNextButton() {
        disableSubmitButton()
    }
}

