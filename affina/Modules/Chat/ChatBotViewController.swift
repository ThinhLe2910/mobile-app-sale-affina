//
//  ChatBotViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 17/01/2023.
//

import UIKit
import WebKit
import SnapKit

class ChatBotViewController: BaseViewController {
    
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideHeaderBase()
        containerBaseView.hide()
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(BaseTabBarViewController.TABBAR_HEIGHT)
            make.top.equalToSuperview()//.inset(UIConstants.Layout.headerHeight)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let url = URL(string: "https://krissirk0906.github.io/chatbox.html") {
            let request = URLRequest(url: url)
            //                request.allHTTPHeaderFields = ["X-API-KEY": ""]
            DispatchQueue.main.async { [weak self] in
                self?.webView.load(request)
            }
        }
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
//    }

}

// MARK: WKNavigationDelegate
extension ChatBotViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.Logs(event: .error, message: "Error loading HTML: \(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Logger.Logs(event: .error, message: "Error loading HTML: \(error)")
    }
}

// MARK: UIWebViewDelegate
extension ChatBotViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        Logger.Logs(event: .error, message: "Error loading HTML: \(error)")
    }
}
