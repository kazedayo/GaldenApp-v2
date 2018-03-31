//
//  FirstLoginViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 7/11/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift
import SnapKit

class FirstLoginViewController: UIViewController,UITextFieldDelegate {
    
    let loginText = UILabel()
    let emailField = UITextField()
    let passwordField = UITextField()
    let loginButton = UIButton()
    
    let keychain = KeychainSwift()
    var window: UIWindow?
    
    var email = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hero.isEnabled = true
        hero.modalAnimationType = .zoom
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        loginText.hero.modifiers = [.fade,.position(CGPoint(x:UIScreen.main.bounds.midX,y:100))]
        loginText.text = "請登入你的膠登帳戶"
        loginText.textColor = .white
        loginText.textAlignment = .center
        view.addSubview(loginText)
        
        emailField.delegate = self
        emailField.borderStyle = .roundedRect
        emailField.placeholder = "email"
        view.addSubview(emailField)
        
        passwordField.delegate = self
        passwordField.borderStyle = .roundedRect
        passwordField.placeholder = "密碼"
        view.addSubview(passwordField)
        
        loginButton.hero.id = "button"
        loginButton.layer.cornerRadius = 5
        loginButton.backgroundColor = UIColor(rgb: 0x0076ff)
        loginButton.setTitle("登入", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        view.addSubview(loginButton)
        
        loginText.snp.makeConstraints {
            (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
        }
        
        emailField.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(loginText.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
        
        passwordField.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(emailField.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
        
        loginButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(passwordField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loginButtonPressed() {
        emailField.endEditing(true)
        passwordField.endEditing(true)
        if (emailField.text == "" || passwordField.text == "") {
            let alert = UIAlertController(title:"注意",message:"帳戶/密碼不能留空",preferredStyle:.alert)
            alert.addAction(UIAlertAction(title:"OK",style:.cancel,handler:nil))
            present(alert,animated: true,completion: nil)
        } else {
            HKGaldenAPI.shared.login(email: email, password: password, completion: {
                [weak self] in
                HKGaldenAPI.shared.getUserDetail(completion: {
                    [weak self] username, userid in
                    if (username == "") {
                        let alert = UIAlertController(title:"登入失敗",message:"請確認帳戶/密碼無誤",preferredStyle:.alert)
                        alert.addAction(UIAlertAction(title:"OK",style:.cancel,handler:nil))
                        self?.present(alert,animated: true,completion: nil)
                    } else {
                        self?.keychain.set(username, forKey: "userName")
                        self?.keychain.set(userid, forKey: "userID")
                        self?.keychain.set(true, forKey: "isLoggedIn")
                        self?.present(UINavigationController(rootViewController: ThreadListViewController()), animated: true, completion: nil)
                    }
                })
            })
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case emailField:
            email = emailField.text!
        case passwordField:
            password = passwordField.text!
        default:
            break
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
