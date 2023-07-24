//
//  WebViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 25/05/2022.
//

import UIKit
import WebKit

class WebViewController: BaseViewController, WKUIDelegate, WKNavigationDelegate {
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.appColor(.greenMain)
        return indicator
    }()
    
    private lazy var backImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "ic_back")
        return image
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var downloadButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("DOWNLOADS".localize(), for: .normal)
        return button
    }()
    
    private var url: URL?
    private var canDownload: Bool = false {
        didSet {
            if canDownload {
                rightBaseImage.show()
            }
            else {
                rightBaseImage.hide(isImmediate: true)
            }
        }
    }
    
    
    private var redirectUrl: String = ""
    private var isRedirectedToApp: Bool = false
    var redirectCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let myUrl = url else { return }
        let request = URLRequest(url: myUrl)
        webView.load(request)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
    }

    override func initViews() {
        view.backgroundColor = UIColor.appColor(.whiteMain)
        containerBaseView.addSubview(webView)
        
        addBlurStatusBar()
        addBlurEffect(headerBaseView)
        
        rightBaseImage.image = UIImage(named: "ic_download_doc")?.withRenderingMode(.alwaysTemplate)
        rightBaseImage.tintColor = .appColor(.black)
        rightBaseImage.addTapGestureRecognizer {
            
            if let url = self.url {
                //            Downloader.load(URL: URL)
                FileDownloader.loadFileAsync(url: url) { (path, error) in
                    print("PDF File downloaded to : \(path!)")
//                    self.queueBasePopup(icon: UIImage(named: "ic_check_circle"), title: "Thành công", desc: "Tải xuống thành công!", okTitle: "AGREE".localize(), cancelTitle: "") {
//                        self.hideBasePopup()
//                    } handler: {
//                    }
                }
            }
        }
//        view.addSubview(backButton)
//        view.addSubview(backImage)
        
        view.addSubview(activityIndicator)
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        webView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(containerBaseView.safeArea.top)//.offset(UIConstants.Layout.Padding.top + UIConstants.heightConstraint(7))
            make.bottom.equalTo(containerBaseView.safeArea.bottom).inset((UIConstants.Layout.Padding.top + UIConstants.Layout.Padding.size16) * 2)
        }
        
//        backButton.snp.makeConstraints { make in
//            make.center.equalTo(backImage.snp_center)
//        }
//        
//        backImage.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(UIConstants.widthConstraint(15))
//            make.top.equalToSuperview().offset(UIConstants.Layout.Padding.top + UIConstants.heightConstraint(7))
//            make.width.height.equalTo(30)
//        }
//        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(45)
        }
    }
    
    func setUrl(url: String, canDownload: Bool = false) {
        guard let url = URL(string: url) else {
            return
        }
        self.url = url
        self.canDownload = canDownload
    }
    
    func setRedirectUrl(url: String, isRedirectedToApp: Bool) {
        redirectUrl = url
        self.isRedirectedToApp = isRedirectedToApp
    }
    
    @objc private func didTapBackButton() {
            self.popViewController()
    }
    
    private func showIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showIndicator(show: false)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showIndicator(show: true)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        Logger.Logs(message: navigation.)
    }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if(navigationAction.navigationType == .other) {
            if let redirectedUrl = navigationAction.request.url {
                //do what you need with url
                //self.delegate?.openURL(url: redirectedUrl)
                Logger.Logs(message: redirectedUrl)
                if self.redirectUrl == redirectedUrl.absoluteString {
                    if isRedirectedToApp {
                        self.navigationController?.popViewController(animated: true)
                        redirectCallback?()
                    }
                }
                decisionHandler(.allow)
            }
//            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}
