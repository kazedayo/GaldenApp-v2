//
//  LoginViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 17/9/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import WebKit
import SwiftEntryKit
import Apollo

class LoginViewController: UIViewController,WKNavigationDelegate {
    
    lazy var loginButton = UIBarButtonItem(title: "登入", style: .done, target: self, action: #selector(loginButtonPressed(_:)))
    let webView = WKWebView()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.navigationItem.title = "會員資料"
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = loginButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        webView.navigationDelegate = self
        
        let label = UILabel()
        label.text = "未登入，請先登入"
        label.textColor = .lightGray
        view.addSubview(label)
        
        label.snp.makeConstraints {
            (make) -> Void in
            make.center.equalToSuperview()
        }

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
    
    @objc func loginButtonPressed(_ sender: UIButton) {
        //print("entry displayed")
        let url = URL(string: "https://hkgalden.org/oauth/v1/authorize?client_id=15897154848030720.apis.hkgalden.org")
        let request = URLRequest(url: url!)
        webView.load(request)
        let modalVC = UIViewController()
        let modalNav = UINavigationController(rootViewController: modalVC)
        modalVC.view = webView
        modalNav.modalPresentationStyle = .formSheet
        modalVC.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
        present(modalNav, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlStr = navigationAction.request.url?.absoluteString
        if (urlStr?.contains("http://localhost/callback"))! {
            let userKey = urlStr!.replacingOccurrences(of: "http://localhost/callback?token=", with: "")
            //print(userKey)
            keychain.set(userKey, forKey: "userKey")
            //reconfigure apollo
            apollo = Configurations.shared.configureApollo()
            let getSessionUserQuery = GetSessionUserQuery()
            apollo.fetch(query: getSessionUserQuery,cachePolicy: .fetchIgnoringCacheData) {
                [weak self] result,error in
                sessionUser = result?.data?.sessionUser
                self?.dismiss(animated: true, completion: nil)
                var controllers = (self?.tabBarController?.viewControllers)!
                let sessionUserViewController = SessionUserViewController()
                sessionUserViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "user"), tag: 1)
                sessionUserViewController.tabBarItem.imageInsets = UIEdgeInsets.init(top: 6, left: 0, bottom: -6, right: 0)
                controllers[1] = sessionUserViewController
                self?.tabBarController?.setViewControllers(controllers, animated: false)
            }
        }
        decisionHandler(.allow)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }

}
