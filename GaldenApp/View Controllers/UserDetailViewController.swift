//
//  UserDetailViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 19/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift
import SideMenu
import PKHUD
import RealmSwift

class UserDetailViewController: UITableViewController,UINavigationControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var leaveNameTextField: UITextField!
    @IBOutlet weak var blocklistButton: UIButton!
    
    let api = HKGaldenAPI()
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loggedIn()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        leaveNameTextField.endEditing(true)
        keychain.set(leaveNameTextField.text!, forKey: "LeaveNameText")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        api.logout {
            weak var pvc = self.presentingViewController
            self.keychain.delete("isLoggedIn")
            self.dismiss(animated: true, completion: {
                pvc?.performSegue(withIdentifier: "logoutSegue", sender: pvc)
            })
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
                self.api.changeName(name: (textField?.text)!, completion: {
                    status,newName in
                    if status == "true" {
                        HUD.flash(.success,delay: 1.0)
                        let keychain = KeychainSwift()
                        keychain.set(newName, forKey: "userName")
                        self.loggedIn()
                    } else if status == "false" {
                        HUD.flash(.error,delay: 1.0)
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "冇嘢啦",style:.cancel,handler:nil))
        present(alert,animated: true,completion: nil)
    }
    
    func loggedIn() {
        self.userName.text = keychain.get("userName")! + " (UID: " + keychain.get("userID")! + ")"
        leaveNameTextField.text = keychain.get("LeaveNameText")
        self.userName.textColor = UIColor.lightGray

    }
}
