//
//  PagePopoverTableViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 22/2/2018.
//  Copyright © 2018年 1080@galden. All rights reserved.
//

import UIKit

class PagePopoverTableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var threadID: String?
    var pageCount: Int = 0
    var pageSelected: Int?
    var mainVC: ContentViewController?
    let tableView = UITableView()
    let backgroundView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        backgroundView.layer.cornerRadius = 10
        backgroundView.hero.modifiers = [.position(CGPoint(x: view.frame.midX, y: 1000))]
        view.addSubview(backgroundView)
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        tableView.separatorStyle = .none
        tableView.register(PageSelectTableViewCell.self, forCellReuseIdentifier: "PageSelectTableViewCell")
        tableView.tableFooterView = UIView()
        backgroundView.addSubview(tableView)
        
        backgroundView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-15)
            make.height.equalTo(150)
        }
        
        tableView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: IndexPath.init(row: pageSelected!-1, section: 0), animated: true, scrollPosition: .top)
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
        return pageCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageSelectTableViewCell") as! PageSelectTableViewCell
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = .darkGray
        cell.selectedBackgroundView = bgColorView
        
        cell.pageNo.text = "第\(indexPath.row+1)頁"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pageSelected = indexPath.row + 1
        dismiss(animated: true, completion: nil)
        mainVC?.unwindToContent(pageSelected: pageSelected!)
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
