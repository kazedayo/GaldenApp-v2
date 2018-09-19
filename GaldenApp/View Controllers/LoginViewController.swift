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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        self.title = "會員資料"
        webView.navigationDelegate = self
        
        navigationItem.rightBarButtonItem = loginButton
        
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
        print("entry displayed")
        var attributes = EntryAttributes.shared.centerEntryZoom()
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.8)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.8)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        let url = URL(string: "https://hkgalden.org/oauth/v1/authorize?client_id=15897154848030720.apis.hkgalden.org")
        let request = URLRequest(url: url!)
        webView.load(request)
        SwiftEntryKit.display(entry: webView, using: attributes)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlStr = navigationAction.request.url?.absoluteString
        if (urlStr?.contains("http://localhost/callback"))! {
            let userKey = urlStr!.replacingOccurrences(of: "http://localhost/callback?token=", with: "")
            print(userKey)
            keychain.set(userKey, forKey: "userKey")
            apollo = {
                let configuration = URLSessionConfiguration.default
                // Add additional headers as needed
                configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(keychain.get("userKey") ?? "")"] // Replace `<token>`
                
                let url = URL(string: "https://hkgalden.org/_")!
                
                return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
            }()
            SwiftEntryKit.dismiss()
            var controllers = (tabBarController?.viewControllers)!
            let userViewController = UserViewController()
            userViewController.tabBarItem = UITabBarItem(title: "會員資料", image: UIImage(named: "user"), tag: 1)
            let nav = UINavigationController(rootViewController: userViewController)
            controllers[1] = nav
            tabBarController?.setViewControllers(controllers, animated: false)
        }
        decisionHandler(.allow)
    }

}
