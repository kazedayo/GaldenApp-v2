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
    lazy var swipeToDismiss = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    var backgroundViewOriginalPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.selectRow(at: IndexPath.init(row: pageSelected!-1, section: 0), animated: true, scrollPosition: .top)
        backgroundViewOriginalPoint = CGPoint(x: backgroundView.frame.minX, y: backgroundView.frame.minY)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(swipeToDismiss)
        
        backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        backgroundView.layer.cornerRadius = 10
        backgroundView.hero.modifiers = [.position(CGPoint(x: view.frame.midX, y: 1000))]
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowOffset = CGSize.zero
        backgroundView.layer.shadowRadius = 10
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
            make.bottom.equalTo(view.snp.bottomMargin).offset(-15)
            make.height.equalTo(200)
            make.width.lessThanOrEqualTo(500)
            make.leadingMargin.greaterThanOrEqualTo(15)
            make.trailingMargin.greaterThanOrEqualTo(-15)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
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
        return pageCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageSelectTableViewCell") as! PageSelectTableViewCell
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        cell.selectedBackgroundView = bgColorView
        
        cell.pageNo.text = "第\(indexPath.row+1)頁"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pageSelected = indexPath.row + 1
        dismiss(animated: true, completion: nil)
        mainVC?.unwindToContent(pageSelected: pageSelected!)
    }
    
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.backgroundView.frame = CGRect(x: backgroundViewOriginalPoint.x, y: backgroundViewOriginalPoint.y + (touchPoint.y - initialTouchPoint.y), width: self.backgroundView.frame.size.width, height: self.backgroundView.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.backgroundView.frame = CGRect(x: self.backgroundViewOriginalPoint.x, y: self.backgroundViewOriginalPoint.y, width: self.backgroundView.frame.size.width, height: self.backgroundView.frame.size.height)
                })
            }
        }
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
