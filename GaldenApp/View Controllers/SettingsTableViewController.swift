//
//  SettingsTableViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 6/9/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyStoreKit

class SettingsTableViewController: UITableViewController {
    
    var clearHistoryCell = UITableViewCell()
    var sourceCell = UITableViewCell()
    var iapCell = UITableViewCell()
    
    let clearHistoryButton = UIButton()
    let sourceCodeButton = UIButton()
    let adIAPButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "設定"
        if keychain.getBool("noAd") == true {
            adIAPButton.isEnabled = false
        } else {
            adIAPButton.isEnabled = true
        }
        tableView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tableView.separatorColor = UIColor(white: 0.15, alpha: 1)
        clearHistoryCell.backgroundColor = UIColor(white: 0.2, alpha: 1)
        sourceCell.backgroundColor = UIColor(white: 0.2, alpha: 1)
        iapCell.backgroundColor = UIColor(white: 0.2, alpha: 1)
        
        clearHistoryButton.setTitleColor(.red, for: .normal)
        clearHistoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        clearHistoryButton.setTitle(" 清除歷史", for: .normal)
        clearHistoryButton.addTarget(self, action: #selector(clearButtonPressed(_:)), for: .touchUpInside)
        clearHistoryCell.addSubview(clearHistoryButton)
        
        sourceCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        sourceCodeButton.setTitle(" Source", for: .normal)
        sourceCodeButton.tintColor = .white
        sourceCodeButton.addTarget(self, action: #selector(sourceButtonPressed(_:)), for: .touchUpInside)
        sourceCell.addSubview(sourceCodeButton)
        
        adIAPButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        adIAPButton.setTitle(" 捐獻", for: .normal)
        adIAPButton.tintColor = .white
        adIAPButton.addTarget(self, action: #selector(adIAPButtonPressed(_:)), for: .touchUpInside)
        iapCell.addSubview(adIAPButton)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        clearHistoryButton.snp.makeConstraints {
            (make) -> Void in
            make.center.equalToSuperview()
        }
        
        sourceCodeButton.snp.makeConstraints {
            (make) -> Void in
            make.center.equalToSuperview()
        }
        
        adIAPButton.snp.makeConstraints {
            (make) -> Void in
            make.center.equalToSuperview()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return self.clearHistoryCell
        case 1: return self.sourceCell
        case 2: return self.iapCell
        default: fatalError("unknown row")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "一般設定"
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    @objc func adIAPButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "捐獻箱", message: "支持廢青開發工作", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "畀錢!", style: .default, handler: {
            _ in
            NetworkActivityIndicatorManager.networkOperationStarted()
            SwiftyStoreKit.purchaseProduct("1080signaladfree", quantity: 1, atomically: true) { result in
                NetworkActivityIndicatorManager.networkOperationFinished()
                switch result {
                case .success(_):
                    keychain.set(true, forKey: "noAd")
                    self.adIAPButton.isEnabled = false
                    let success = UIAlertController(title: "購買成功!", message: "多謝支持!", preferredStyle: .alert)
                    success.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(success, animated: true, completion: nil)
                case .error(let error):
                    let failure = UIAlertController(title: "購買失敗:(", message: "debug info: \(error.code)", preferredStyle: .alert)
                    failure.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(failure, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "不了", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
