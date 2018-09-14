//
//  LoginViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 24/7/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift

class LoginViewController: UIViewController {

    let keychain = KeychainSwift()
    let loginButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        self.title = "會員資料"
        
        loginButton.setTitle("登入", for: .normal)
        loginButton.clipsToBounds = true
        loginButton.layer.cornerRadius = 5
        loginButton.backgroundColor = UIColor(hexRGB: "007aff")
        loginButton.addTarget(self, action: #selector(loginButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(loginButton)
        
        loginButton.snp.makeConstraints {
            (make) -> Void in
            make.center.equalTo(view.snp.center)
            make.width.equalTo(300)
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
        
    }
    
}
