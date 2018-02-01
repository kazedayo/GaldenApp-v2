//
//  BlockedUserViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 28/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit

class BlockedUserViewController: UITableViewController {
    
    var blockedUsers = [BlockedUsers]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        HKGaldenAPI.shared.getBlockedUsers(completion: {
            blocked in
            self.blockedUsers = blocked
            self.tableView.reloadData()
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserTableViewCell") as! BlockedUserTableViewCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        cell.selectedBackgroundView = bgColorView
        cell.userLabel.text = blockedUsers[indexPath.row].userName
        cell.idLabel.text = "UID: " + blockedUsers[indexPath.row].id
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actionsheet = UIAlertController.init(title: blockedUsers[indexPath.row].userName, message: "你想...", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction.init(title: "解扑", style: .default, handler: {
            _ in
            HKGaldenAPI.shared.unblockUser(uid: self.blockedUsers[indexPath.row].id, completion: {
                status,userName in
                self.blockedUsers.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.middle)
            })
        }))
        actionsheet.addAction(UIAlertAction.init(title: "冇嘢啦", style: .cancel, handler: nil))
        present(actionsheet,animated: true,completion: nil)
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
