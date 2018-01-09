//
//  ContentSideMenuViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 8/1/2018.
//  Copyright © 2018年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift

class ContentSideMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var upvote: Int = 0
    var downvote: Int = 0
    var threadTitle: String?
    var opName: String?
    var threadID: String?
    var pageCount: Int = 0
    var pageSelected: Int?
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var pageSelectTableView: UITableView!
    
    let api = HKGaldenAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageSelectTableView.delegate = self
        pageSelectTableView.dataSource = self
        pageSelectTableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        upvoteButton.setTitle("正皮: \(upvote)", for: .normal)
        downvoteButton.setTitle("負皮: \(downvote)", for: .normal)
        pageSelectTableView.selectRow(at: IndexPath.init(row: pageSelected!-1, section: 0), animated: true, scrollPosition: .top)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageSelectTableViewCell") as! PageSelectTableViewCell
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.15, green:0.15, blue:0.15, alpha:1.0)
        cell.selectedBackgroundView = bgColorView
        
        cell.pageNo.text = "第\(indexPath.row+1)頁"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pageSelected = indexPath.row + 1
        performSegue(withIdentifier: "unwindToContent", sender: self)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        let shared = threadTitle! + " // by: " + opName! + "\nShared via 1080-SIGNAL \nhttps://hkgalden.com/view/" + threadID!
        let share = UIActivityViewController(activityItems:[shared],applicationActivities:nil)
        share.excludedActivityTypes = [.airDrop,.addToReadingList,.assignToContact,.openInIBooks,.saveToCameraRoll]
        present(share,animated: true,completion: nil)
    }
    
    @IBAction func upvoteButtonPressed(_ sender: UIButton) {
        api.rate(threadID: threadID!, rate: "g", completion: {
            self.upvote += 1
            self.upvoteButton.setTitle("正皮: \(self.upvote)", for: .normal)
        })
    }
    
    @IBAction func downvoteButtonPressed(_ sender: UIButton) {
        api.rate(threadID: threadID!, rate: "b", completion: {
            self.downvote += 1
            self.downvoteButton.setTitle("負皮: \(self.downvote)", for: .normal)
        })
    }
    
    @IBAction func leaveNamePressed(_ sender: UIButton) {
        let keychain = KeychainSwift()
        let alert = UIAlertController.init(title: "一鍵留名", message: "確定?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction.init(title: "55", style: .destructive, handler: {
            _ in
            self.api.reply(topicID: self.threadID!, content: keychain.get("LeaveNameText")!.replacingOccurrences(of: "\\n", with: "\n"), completion: {
                [weak self] in
                self?.performSegue(withIdentifier: "unwindToContent", sender: self)
            })
        }))
        alert.addAction(UIAlertAction.init(title: "不了", style: .cancel, handler: nil))
        present(alert,animated: true)
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
