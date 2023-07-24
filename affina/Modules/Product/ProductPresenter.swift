//
//  ProductPresenter.swift
//  affina
//
//  Created by Intelin MacHD on 24/04/2023.
//

protocol ProductListViewDelegate {
    func lockUI()
    func unLockUI()
    
    func showError(error: ApiError)
    
    func updateListFeaturedProducts(list: [HomeFeaturedProduct])
}

class ProductListPresenter {
    private var delegate: ProductListViewDelegate?
    
    private let homeService = HomeService()
    
    func setViewDelegate(delegate: ProductListViewDelegate?) {
        self.delegate = delegate
    }
    
    func getListFeaturedProducts() {
        self.delegate?.lockUI()
        homeService.getListFeaturedProducts { [weak self] result in
            self?.delegate?.unLockUI()
            switch result {
                case .success(let data):
                    guard let list = data.data else { return }
                    Logger.Logs(message: list)
                    self?.delegate?.updateListFeaturedProducts(list: list)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
            }
        }
    }
}
