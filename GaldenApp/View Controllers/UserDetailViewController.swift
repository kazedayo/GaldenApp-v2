//
//  UserDetailViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 19/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift
import PKHUD
import RealmSwift
import IQKeyboardManagerSwift
import SwiftyStoreKit

class UserDetailViewController: UIViewController,UINavigationControllerDelegate,UITextViewDelegate,UIPopoverPresentationControllerDelegate {

    let backgroundView = UIView()
    let secondaryBackgroundView = UIView()
    let userName = UILabel()
    let userID = UILabel()
    let logoutButton = UIButton()
    let leaveNameTextView = IQTextView()
    let changeNameButton = UIButton()
    let clearHistoryButton = UIButton()
    let sourceCodeButton = UIButton()
    let adIAPButton = UIButton()
    
    lazy var tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerHandler(_:)))
    
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if keychain.getBool("noAd") == true {
            adIAPButton.isEnabled = false
        } else {
            adIAPButton.isEnabled = true
        }
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(tapToDismiss)
        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        leaveNameTextView.endEditing(true)
        keychain.set(leaveNameTextView.text!, forKey: "LeaveNameText")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        if segue.identifier == ("detailPop") {
            let popoverViewController = segue.destination as! UserDetailPopoverViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.popoverPresentationController!.permittedArrowDirections = .init(rawValue: 0)
        }
    }*/
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func logoutButtonPressed(_ sender: UIButton) {
        HKGaldenAPI.shared.logout {
            weak var pvc = self.presentingViewController
            self.keychain.delete("isLoggedIn")
            self.dismiss(animated: true, completion: {
                pvc?.present(FirstLoginViewController(), animated: true, completion: nil)
            })
        }
    }
    
    func setupUI() {
        backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        backgroundView.layer.cornerRadius = 10
        backgroundView.hero.modifiers = [.position(CGPoint(x: view.frame.midX, y: 1000))]
        view.addSubview(backgroundView)
        
        secondaryBackgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        secondaryBackgroundView.layer.cornerRadius = 10
        secondaryBackgroundView.hero.modifiers = [.position(CGPoint(x: view.frame.midX, y: 700))]
        view.addSubview(secondaryBackgroundView)
        
        userName.text = keychain.get("userName")!
        userName.textColor = .white
        userName.font = UIFont.systemFont(ofSize: 15)
        backgroundView.addSubview(userName)
        
        userID.text = keychain.get("userID")!
        userID.textColor = .lightGray
        userID.font = UIFont.systemFont(ofSize: 12)
        backgroundView.addSubview(userID)
        
        leaveNameTextView.placeholder = "自訂一鍵留名"
        leaveNameTextView.text = keychain.get("LeaveNameText")
        leaveNameTextView.layer.cornerRadius = 5
        backgroundView.addSubview(leaveNameTextView)
        
        logoutButton.setTitle("登出", for: .normal)
        logoutButton.backgroundColor = UIColor(rgb: 0xfc3158)
        logoutButton.layer.cornerRadius = 5
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed(_:)), for: .touchUpInside)
        backgroundView.addSubview(logoutButton)
        
        changeNameButton.setImage(UIImage(named: "changeName"), for: .normal)
        changeNameButton.tintColor = .white
        changeNameButton.imageView?.contentMode = .scaleAspectFit
        changeNameButton.addTarget(self, action: #selector(changeNameButtonPressed(_:)), for: .touchUpInside)
        
        clearHistoryButton.setImage(UIImage(named: "clearHistory"), for: .normal)
        clearHistoryButton.tintColor = UIColor(rgb: 0xfc3158)
        clearHistoryButton.imageView?.contentMode = .scaleAspectFit
        clearHistoryButton.addTarget(self, action: #selector(clearButtonPressed(_:)), for: .touchUpInside)
        
        sourceCodeButton.setImage(UIImage(named: "sourceCode"), for: .normal)
        sourceCodeButton.tintColor = .white
        sourceCodeButton.imageView?.contentMode = .scaleAspectFit
        sourceCodeButton.addTarget(self, action: #selector(sourceButtonPressed(_:)), for: .touchUpInside)
        
        adIAPButton.setImage(UIImage(named: "noAds"), for: .normal)
        adIAPButton.tintColor = .white
        adIAPButton.imageView?.contentMode = .scaleAspectFit
        adIAPButton.addTarget(self, action: #selector(adIAPButtonPressed(_:)), for: .touchUpInside)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.addArrangedSubview(changeNameButton)
        stackView.addArrangedSubview(clearHistoryButton)
        stackView.addArrangedSubview(sourceCodeButton)
        stackView.addArrangedSubview(adIAPButton)
        secondaryBackgroundView.addSubview(stackView)
        
        backgroundView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-15)
            make.height.equalTo(200)
        }
        
        secondaryBackgroundView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(backgroundView.snp.top).offset(-10)
            make.height.equalTo(45)
        }
        
        userName.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(backgroundView).offset(10)
            make.leading.equalTo(backgroundView).offset(15)
        }
        
        userID.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(userName.snp.bottom).offset(10)
            make.leading.equalTo(backgroundView).offset(15)
        }
        
        leaveNameTextView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(userID.snp.bottom).offset(10)
            make.leading.equalTo(backgroundView).offset(15)
            make.trailing.equalTo(backgroundView).offset(-15)
        }
        
        logoutButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(leaveNameTextView.snp.bottom).offset(10)
            make.leading.equalTo(backgroundView).offset(15)
            make.trailing.equalTo(backgroundView).offset(-15)
            make.bottom.equalTo(backgroundView).offset(-15)
        }
        
        stackView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview()
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc func tapGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sourceButtonPressed(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: "https://github.com/kazedayo/GaldenApp-v2")!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: "https://github.com/kazedayo/GaldenApp-v2")!)
        }
    }
    
    @objc func clearButtonPressed(_ sender: UIButton) {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        let alert = UIAlertController.init(title: "搞掂", message: "已清除回帶記錄", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        present(alert,animated: true,completion: nil)
    }
    
    @objc func changeNameButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "改名怪", message: "你想改咩名?", preferredStyle: .alert)
        let empty = UIAlertController.init(title: "注意", message: "用戶名不能留空", preferredStyle: .alert)
        empty.addAction(UIAlertAction(title: "OK",style:.cancel,handler:nil))
        alert.addTextField {
            textField in
            textField.placeholder = "新名"
        }
        alert.addAction(UIAlertAction(title:"改名",style:.default,handler:{
            [weak alert] _ in
            let textField = alert?.textFields![0]
            if textField?.text == "" {
                self.present(empty,animated: true,completion: nil)
            } else {
                HKGaldenAPI.shared.changeName(name: (textField?.text)!, completion: {
                    status,newName in
                    if status == "true" {
                        HUD.flash(.success,delay: 1.0)
                        let keychain = KeychainSwift()
                        keychain.set(newName, forKey: "userName")
                        self.setupUI()
                    } else if status == "false" {
                        HUD.flash(.error,delay: 1.0)
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "冇嘢啦",style:.cancel,handler:nil))
        present(alert,animated: true,completion: nil)
    }
    
    @objc func adIAPButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "去除廣告", message: "支持廢青開發工作", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "畀錢!", style: .default, handler: {
            _ in
            SwiftyStoreKit.purchaseProduct("1080signaladfree", quantity: 1, atomically: true) { result in
                switch result {
                case .success(_):
                    self.keychain.set(true, forKey: "noAd")
                    self.adIAPButton.isEnabled = false
                    let success = UIAlertController(title: "購買成功!", message: "多謝支持!(重新啓動/入post再出post就會冇咗個廣告banner啦!)", preferredStyle: .alert)
                    success.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(success, animated: true, completion: nil)
                case .error(let error):
                    let failure = UIAlertController(title: "購買失敗:(", message: "debug info: \(error.code.rawValue)", preferredStyle: .alert)
                    failure.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(failure, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "恢復購買", style: .default, handler: {
            _ in
            SwiftyStoreKit.restorePurchases(atomically: true) { results in
                if results.restoreFailedPurchases.count > 0 {
                    let failure = UIAlertController(title: "恢復失敗:(", message: "請稍後再試", preferredStyle: .alert)
                    failure.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(failure, animated: true, completion: nil)
                }
                else if results.restoredPurchases.count > 0 {
                    self.keychain.set(true, forKey: "noAd")
                    let success = UIAlertController(title: "恢復成功", message: "多謝支持!(重新啓動/入post再出post就會冇咗個廣告banner啦!)", preferredStyle: .alert)
                    success.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(success, animated: true, completion: nil)
                }
                else {
                    let none = UIAlertController(title: "冇嘢恢復", message: "你未畀錢喎ching #ng#", preferredStyle: .alert)
                    none.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(none, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "不了", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
