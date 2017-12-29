//
//  FirstLoginViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 7/11/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift

class FirstLoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var loginText: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let keychain = KeychainSwift()
    let api = HKGaldenAPI()
    var window: UIWindow?
    
    var email = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        loginText.heroModifiers = [.fade,.position(CGPoint(x:UIScreen.main.bounds.midX,y:100))]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        emailField.endEditing(true)
        passwordField.endEditing(true)
        if (emailField.text == "" || passwordField.text == "") {
            let alert = UIAlertController(title:"注意",message:"帳戶/密碼不能留空",preferredStyle:.alert)
            alert.addAction(UIAlertAction(title:"OK",style:.cancel,handler:nil))
            present(alert,animated: true,completion: nil)
        } else {
            api.login(email: email, password: password, completion: {
                [weak self] in
                self?.api.getUserDetail(completion: {
                    [weak self] username, userid in
                    if (username == "") {
                        let alert = UIAlertController(title:"登入失敗",message:"請確認帳戶/密碼無誤",preferredStyle:.alert)
                        alert.addAction(UIAlertAction(title:"OK",style:.cancel,handler:nil))
                        self?.present(alert,animated: true,completion: nil)
                    } else {
                        self?.keychain.set(username, forKey: "userName")
                        self?.keychain.set(userid, forKey: "userID")
                        self?.keychain.set(true, forKey: "isLoggedIn")
                        self?.window?.rootViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "ThreadList")
                        self?.performSegue(withIdentifier: "Start", sender: self)
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
