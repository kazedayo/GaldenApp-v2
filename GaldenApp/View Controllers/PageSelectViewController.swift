//
//  PageSelectViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 16/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit

class PageSelectViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var pageCount: Double = 0.0
    var pageSelected: Int = 0
    var titleText: String?
    var mainVC: ThreadListViewController?
    
    let tableView = UITableView()
    let titleLabel = UILabel()
    let titleView = UIView()
    let cancelButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        titleView.hero.modifiers = [.position(CGPoint(x: self.view.frame.midX, y: 100))]
        titleView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        titleView.layer.cornerRadius = 10
        view.addSubview(titleView)
        
        titleLabel.text = titleText!
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = .lightGray
        titleView.addSubview(titleLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor(white: 0.2, alpha: 1)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.hero.modifiers = [.scale(0.5)]
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tableView.layer.cornerRadius = 10
        tableView.register(PageSelectTableViewCell.self, forCellReuseIdentifier: "PageSelectTableViewCell")
        view.addSubview(tableView)
        
        cancelButton.setTitle("不了", for: .normal)
        cancelButton.hero.modifiers = [.position(CGPoint(x: self.view.frame.midX, y: 1000))]
        cancelButton.backgroundColor = UIColor(rgb: 0xfc3158)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cancelButton.layer.cornerRadius = 10
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        titleView.snp.makeConstraints {
            (make) -> Void in
            make.centerY.equalToSuperview().offset(-120)
            make.leading.equalTo(75)
            make.trailing.equalTo(-75)
        }
        
        titleLabel.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(10)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-10)
        }
        
        tableView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(titleView.snp.bottom).offset(20)
            make.leading.equalTo(75)
            make.trailing.equalTo(-75)
            make.height.equalTo(200)
        }
        
        cancelButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(tableView.snp.bottom).offset(20)
            make.leading.equalTo(75)
            make.trailing.equalTo(-75)
            make.height.equalTo(35)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Int(pageCount)
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageSelectTableViewCell", for: indexPath) as! PageSelectTableViewCell

        // Configure the cell...
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        cell.selectedBackgroundView = bgColorView
        cell.pageNo.text = "第" + String(indexPath.row + 1) + "頁"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pageSelected = (indexPath.row + 1)
        dismiss(animated: true, completion: nil)
        mainVC?.unwindAfterPageSelect(pageSelected: pageSelected)
    }
    
    @objc func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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

    
    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
