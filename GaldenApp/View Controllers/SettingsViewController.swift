//
//  SettingsViewController.swift
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
import SideMenu

class SettingsViewController: UIViewController,UINavigationControllerDelegate,UITextViewDelegate,UIPopoverPresentationControllerDelegate {

    let leaveNameButton = UIButton()
    let leaveNameTextView = IQTextView()
    let changeNameButton = UIButton()
    let clearHistoryButton = UIButton()
    let sourceCodeButton = UIButton()
    let adIAPButton = UIButton()
    
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if keychain.getBool("noAd") == true {
            adIAPButton.isEnabled = false
        } else {
            adIAPButton.isEnabled = true
        }
        
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        setupUI()
        
        // Do any additional setup after loading the view.
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
    
    func setupUI() {
        leaveNameButton.setImage(UIImage(named: "leaveName"), for: .normal)
        leaveNameButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        leaveNameButton.setTitle(" 一鍵留名", for: .normal)
        leaveNameButton.tintColor = .white
        leaveNameButton.imageView?.contentMode = .scaleAspectFit
        leaveNameButton.addTarget(self, action: #selector(leaveNameButtonPressed(_:)), for: .touchUpInside)
        
        changeNameButton.setImage(UIImage(named: "changeName"), for: .normal)
        changeNameButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        changeNameButton.setTitle(" 改名怪", for: .normal)
        changeNameButton.tintColor = .white
        changeNameButton.imageView?.contentMode = .scaleAspectFit
        changeNameButton.addTarget(self, action: #selector(changeNameButtonPressed(_:)), for: .touchUpInside)
        
        clearHistoryButton.setImage(UIImage(named: "clearHistory"), for: .normal)
        clearHistoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        clearHistoryButton.setTitle(" 清除歷史", for: .normal)
        clearHistoryButton.tintColor = UIColor(rgb: 0xfc3158)
        clearHistoryButton.imageView?.contentMode = .scaleAspectFit
        clearHistoryButton.addTarget(self, action: #selector(clearButtonPressed(_:)), for: .touchUpInside)
        
        sourceCodeButton.setImage(UIImage(named: "sourceCode"), for: .normal)
        sourceCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        sourceCodeButton.setTitle(" Source", for: .normal)
        sourceCodeButton.tintColor = .white
        sourceCodeButton.imageView?.contentMode = .scaleAspectFit
        sourceCodeButton.addTarget(self, action: #selector(sourceButtonPressed(_:)), for: .touchUpInside)
        
        adIAPButton.setImage(UIImage(named: "noAds"), for: .normal)
        adIAPButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        if (keychain.getBool("noAd") == false) {
            adIAPButton.setTitle(" 去除廣告", for: .normal)
        } else {
            adIAPButton.setTitle(" 多謝支持!", for: .normal)
        }
        adIAPButton.tintColor = .white
        adIAPButton.imageView?.contentMode = .scaleAspectFit
        adIAPButton.addTarget(self, action: #selector(adIAPButtonPressed(_:)), for: .touchUpInside)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.spacing = 25
        stackView.addArrangedSubview(leaveNameButton)
        stackView.addArrangedSubview(changeNameButton)
        stackView.addArrangedSubview(clearHistoryButton)
        stackView.addArrangedSubview(sourceCodeButton)
        stackView.addArrangedSubview(adIAPButton)
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            (make) -> Void in
            make.centerY.equalToSuperview()
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
        }
    }
    
    @objc func leaveNameButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "一鍵留名", message: "你嘅一鍵留名信息", preferredStyle: .alert)
        alert.addTextField {
            textField in
            textField.placeholder = "自訂一鍵留名"
        }
        alert.addAction(UIAlertAction(title:"OK",style:.default,handler:{
            [weak alert] _ in
            let textField = alert?.textFields![0]
            self.keychain.set((textField?.text)!, forKey: "LeaveNameText")
        }))
        alert.addAction(UIAlertAction(title: "冇嘢啦",style:.cancel,handler:nil))
        present(alert,animated: true,completion: nil)
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
            NetworkActivityIndicatorManager.networkOperationStarted()
            SwiftyStoreKit.purchaseProduct("1080signaladfree", quantity: 1, atomically: true) { result in
                NetworkActivityIndicatorManager.networkOperationFinished()
                switch result {
                case .success(_):
                    self.keychain.set(true, forKey: "noAd")
                    self.adIAPButton.isEnabled = false
                    let success = UIAlertController(title: "購買成功!", message: "多謝支持!(重新啓動/入post再出post就會冇咗個廣告banner啦!)", preferredStyle: .alert)
                    success.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(success, animated: true, completion: nil)
                case .error(let error):
                    let failure = UIAlertController(title: "購買失敗:(", message: "debug info: \(error.code)", preferredStyle: .alert)
                    failure.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(failure, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "恢復購買", style: .default, handler: {
            _ in
            NetworkActivityIndicatorManager.networkOperationStarted()
            SwiftyStoreKit.restorePurchases(atomically: true) { results in
                NetworkActivityIndicatorManager.networkOperationFinished()
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
