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
    var imageCell = UITableViewCell()
    var price: String!
    let imageToggle = UISwitch()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.navigationItem.title = "設定"
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tableView.separatorColor = UIColor(white: 0.15, alpha: 1)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(white: 0.25, alpha:1.0)
        clearHistoryCell.selectedBackgroundView = bgColorView
        sourceCell.selectedBackgroundView = bgColorView
        iapCell.selectedBackgroundView = bgColorView
        imageCell.selectedBackgroundView = UIView()
        clearHistoryCell.backgroundColor = UIColor(white: 0.2, alpha: 1)
        sourceCell.backgroundColor = UIColor(white: 0.2, alpha: 1)
        iapCell.backgroundColor = UIColor(white: 0.2, alpha: 1)
        imageCell.backgroundColor = UIColor(white: 0.2, alpha: 1)
        
        clearHistoryCell.textLabel?.textColor = .red
        clearHistoryCell.textLabel?.text = "重設閲讀位置記錄"
        clearHistoryCell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        clearHistoryCell.textLabel?.adjustsFontForContentSizeCategory = true
        clearHistoryCell.accessoryType = .disclosureIndicator
        
        sourceCell.textLabel?.textColor = .white
        sourceCell.textLabel?.text = "Source"
        sourceCell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        sourceCell.textLabel?.adjustsFontForContentSizeCategory = true
        sourceCell.accessoryType = .disclosureIndicator
        
        iapCell.textLabel?.textColor = .white
        iapCell.textLabel?.text = "捐獻"
        iapCell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        iapCell.textLabel?.adjustsFontForContentSizeCategory = true
        iapCell.accessoryType = .disclosureIndicator
        
        imageCell.textLabel?.textColor = .white
        imageCell.textLabel?.text = "自動載入圖片"
        imageCell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        imageCell.textLabel?.adjustsFontForContentSizeCategory = true
        
        if keychain.getBool("loadImage") == true {
            imageToggle.isOn = true
        } else {
            imageToggle.isOn = false
        }
        imageToggle.onTintColor = UIColor(hexRGB: "#45c17c")
        imageToggle.addTarget(self, action: #selector(imageToggleChanged(_:)), for: .valueChanged)
        imageCell.accessoryView = imageToggle
        
        SwiftyStoreKit.retrieveProductsInfo(["dollarDonation"]) { [weak self] result in
            if let product = result.retrievedProducts.first {
                self?.price = product.localizedPrice!
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return self.clearHistoryCell
        case 1: return self.sourceCell
        case 2: return self.iapCell
        case 3: return self.imageCell
        default: fatalError("unknown row")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "一般設定"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "版本號: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)(\(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: clearHistory(completion: {tableView.deselectRow(at: indexPath, animated: true)})
        case 1: gotoSource(completion: {tableView.deselectRow(at: indexPath, animated: true)})
        case 2: purchaseIAP(completion: {tableView.deselectRow(at: indexPath, animated: true)})
        default: print("no action")
        }
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
    
    func gotoSource(completion: ()->Void) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: "https://github.com/kazedayo/GaldenApp-v2")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: "https://github.com/kazedayo/GaldenApp-v2")!)
        }
        completion()
    }
    
    func clearHistory(completion: ()->Void) {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        let alert = UIAlertController.init(title: "搞掂", message: "已重設閲讀位置記錄", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        present(alert,animated: true,completion: nil)
        completion()
    }
    
    func purchaseIAP(completion: ()->Void) {
        let alert = UIAlertController(title: "捐獻箱(\(price!))", message: "支持廢青開發工作", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "畀錢!", style: .default, handler: {
            _ in
            NetworkActivityIndicatorManager.networkOperationStarted()
            SwiftyStoreKit.purchaseProduct("dollarDonation", quantity: 1, atomically: true) { result in
                NetworkActivityIndicatorManager.networkOperationFinished()
                switch result {
                case .success(_):
                    let success = UIAlertController(title: "購買成功!", message: "多謝支持!", preferredStyle: .alert)
                    success.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(success, animated: true, completion: nil)
                case .error(let error):
                    let failure = UIAlertController(title: "購買失敗:(", message: "debug info: \(error.localizedDescription)", preferredStyle: .alert)
                    failure.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(failure, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "不了", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        completion()
    }
    
    @objc func imageToggleChanged(_ sender: UISwitch) {
        if imageToggle.isOn {
            keychain.set(true, forKey: "loadImage")
        } else {
            keychain.set(false, forKey: "loadImage")
        }
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
