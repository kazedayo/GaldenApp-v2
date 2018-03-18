//
//  UserDetailPopoverViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 23/2/2018.
//  Copyright © 2018年 1080@galden. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD
import KeychainSwift

class UserDetailPopoverViewController: UIViewController {

    @IBOutlet weak var adToggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if adOption.adEnabled == true {
            adToggle.isOn = true
        } else {
            adToggle.isOn = false
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let keychain = KeychainSwift()
        keychain.set(adToggle.isOn, forKey: "adEnabled")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sourceButtonPressed(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: "https://github.com/kazedayo/GaldenApp-v2")!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: "https://github.com/kazedayo/GaldenApp-v2")!)
        }
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        let alert = UIAlertController.init(title: "搞掂", message: "已清除回帶記錄", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        present(alert,animated: true,completion: nil)
    }
    
    @IBAction func changeNameButtonPressed(_ sender: UIButton) {
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
                        self.performSegue(withIdentifier: "unwindFromPop", sender: self)
                    } else if status == "false" {
                        HUD.flash(.error,delay: 1.0)
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "冇嘢啦",style:.cancel,handler:nil))
        present(alert,animated: true,completion: nil)
    }
    
    @IBAction func adToggle(_ sender: UISwitch) {
        if sender.isOn == true {
            adOption.adEnabled = true
        } else {
            adOption.adEnabled = false
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
