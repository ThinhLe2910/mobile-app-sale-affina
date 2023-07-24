//
//  RewardInfoViewController.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit
import WebKit

class RewardInfoViewController: BaseViewController {
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        
        return webView
    }()
    
    private let termsHeaders: [String] = [
        "Quy tắc tích luỹ xu",
//        "Đối tượng áp dụng",
//        "Phương thức đóng phí",
//        "Điều khoản loại trừ",
//        "Điều khoản tham gia"
    ]
    
    var terms: [[ContractTermModel]] = [[
        ContractTermModel(title: "Sed cursus nulla eu mi lacinia:", desc: "Phasellus eleifend mauris at pellentesque placerat. Sed ac viverra eros.", subDescs: []),
        ContractTermModel(title: "Mauris mattis nulla enim:", desc: "Donec consequat felis vel leo iaculis tincidunt. Donec eget nisi eros.", subDescs: []),
        ContractTermModel(title: "Integer imperdiet turpis in dui vehicula:", desc: "Vestibulum faucibus luctus est eget volutpat. Proin eget feugiat leo. Etiam sit amet tincidunt risus, eu lobortis dui.", subDescs: ["Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", "Proin varius mollis augue, eu suscipit odio commodo sit amet.", "Sed quis volutpat mi."]),
    ], [], [], [], []]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerBaseView.hide()
        setupHeaderView()
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight + UIPadding.size24
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ContractBenefitTableViewCell.nib, bundle: nil), forCellReuseIdentifier: ContractBenefitTableViewCell.cellId)
        tableView.register(UINib(nibName: ContractBenefitHeaderView.nib, bundle: nil), forHeaderFooterViewReuseIdentifier: ContractBenefitHeaderView.headerId)
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()//.inset(BaseTabBarViewController.TABBAR_HEIGHT)
            make.top.equalToSuperview().inset(UIConstants.Layout.headerHeight)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let viWebView: String = "https://affina.com.vn/vi/khach-hang/quy-tac-tinh-diem"
        let enWebView: String = "https://affina.com.vn/en/khach-hang/quy-tac-tinh-diem"
        if let url = URL(string: UIConstants.isVietnamese ? viWebView : enWebView) {
            let request = URLRequest(url: url)
            //                request.allHTTPHeaderFields = ["X-API-KEY": ""]
            DispatchQueue.main.async { [weak self] in
                self?.webView.load(request)
            }
        }
    }
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "Quy tắc tích luỹ xu".capitalized.localize()
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        
    }
}

extension RewardInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return termsHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terms[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContractBenefitTableViewCell.cellId, for: indexPath) as? ContractBenefitTableViewCell else { return UITableViewCell() }
        cell.item = terms[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: ContractBenefitHeaderView.headerId) as! ContractBenefitHeaderView
        headerCell.titleLabel.text = termsHeaders[section]
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.backgroundColor = .clear //UIColor(white: 1, alpha: 1)
        headerCell.backgroundView = backgroundView
//        headerCell.addTapGestureRecognizer {
//            self.hideSection(section: section)
//            headerCell.rotateDropdown()
//        }
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

// MARK: WKNavigationDelegate
extension RewardInfoViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.Logs(event: .error, message: "Error loading HTML: \(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Logger.Logs(event: .error, message: "Error loading HTML: \(error)")
    }
}

// MARK: UIWebViewDelegate
extension RewardInfoViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        Logger.Logs(event: .error, message: "Error loading HTML: \(error)")
    }
}
