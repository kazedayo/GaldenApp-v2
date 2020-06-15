//
//  LoginViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 17/9/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import WebKit
import Apollo

class LoginViewController: UIViewController,WKNavigationDelegate,WKUIDelegate {
    
    let webView = WKWebView()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.navigationItem.title = "登入"
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        webView.uiDelegate = self
        let url = URL(string: "https://hkgalden.org/oauth/v1/authorize?client_id=/*YOUR OWN ID*/")
        let request = URLRequest(url: url!)
        webView.load(request)
        view.addSubview(webView)
        
        webView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(view.snp.topMargin)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
        }
        
//        let label = UILabel()
//        label.text = "未登入，請先登入"
//        label.textColor = .systemGray
//        view.addSubview(label)
//
//        label.snp.makeConstraints {
//            (make) -> Void in
//            make.center.equalToSuperview()
//        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlStr = navigationAction.request.url?.absoluteString
        if (urlStr?.contains("http://localhost/callback"))! {
            let userKey = urlStr!.replacingOccurrences(of: "http://localhost/callback?token=", with: "")
            keychain.set(userKey, forKey: "userKey")
            let getSessionUserQuery = GetSessionUserQuery()
            apollo.fetch(query: getSessionUserQuery,cachePolicy: .fetchIgnoringCacheData) {
                [weak self] result in
                guard let data = try? result.get().data else { return }
                sessionUser = data.sessionUser
                //self?.dismiss(animated: true, completion: nil)
                var controllers = (self?.tabBarController?.viewControllers)!
                let sessionUserViewController = SessionUserViewController()
                sessionUserViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "user"), tag: 1)
                controllers[1] = sessionUserViewController
                self?.tabBarController?.setViewControllers(controllers, animated: false)
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {

        let alertController = UIAlertController(title: message, message: nil,
                                                preferredStyle: UIAlertController.Style.alert);

        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) {
            _ in completionHandler()}
        );

        self.present(alertController, animated: true, completion: {});
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }

}
