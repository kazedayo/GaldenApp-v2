//
//  ContentSideMenuViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 8/1/2018.
//  Copyright © 2018年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift
import PKHUD

class ContentMenuViewController: UIViewController {
    
    var upvote: Int = 0
    var downvote: Int = 0
    var rated: String = "false"
    var threadTitle: String?
    var opName: String?
    var threadID: String?
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var lmButton: UIButton!
    
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if keychain.get("LeaveNameText") == "" {
            lmButton.isHidden = true
        }
        if rated == "true" {
            upvoteButton.isEnabled = false
            upvoteButton.backgroundColor = UIColor(red:0.52, green:0.68, blue:0.52, alpha:1.0)
            downvoteButton.isEnabled = false
            downvoteButton.backgroundColor = UIColor(red:0.91, green:0.49, blue:0.49, alpha:1.0)
        }
        upvoteButton.setTitle("正皮: \(upvote)", for: .normal)
        downvoteButton.setTitle("負皮: \(downvote)", for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        let shared = threadTitle! + " // by: " + opName! + "\nShared via 1080-SIGNAL \nhttps://hkgalden.com/view/" + threadID!
        let share = UIActivityViewController(activityItems:[shared],applicationActivities:nil)
        share.excludedActivityTypes = [.airDrop,.addToReadingList,.assignToContact,.openInIBooks,.saveToCameraRoll]
        present(share,animated: true,completion: nil)
    }
    
    @IBAction func upvoteButtonPressed(_ sender: UIButton) {
        HKGaldenAPI.shared.rate(threadID: threadID!, rate: "g", completion: {
            self.upvote += 1
            self.upvoteButton.setTitle("正皮: \(self.upvote)", for: .normal)
            self.upvoteButton.isEnabled = false
            self.upvoteButton.backgroundColor = UIColor(red:0.52, green:0.68, blue:0.52, alpha:1.0)
            self.downvoteButton.isEnabled = false
            self.downvoteButton.backgroundColor = UIColor(red:0.91, green:0.49, blue:0.49, alpha:1.0)
        })
    }
    
    @IBAction func downvoteButtonPressed(_ sender: UIButton) {
        HKGaldenAPI.shared.rate(threadID: threadID!, rate: "b", completion: {
            self.downvote += 1
            self.downvoteButton.setTitle("負皮: \(self.downvote)", for: .normal)
            self.upvoteButton.isEnabled = false
            self.upvoteButton.backgroundColor = UIColor(red:0.52, green:0.68, blue:0.52, alpha:1.0)
            self.downvoteButton.isEnabled = false
            self.downvoteButton.backgroundColor = UIColor(red:0.91, green:0.49, blue:0.49, alpha:1.0)
        })
    }
    
    @IBAction func leaveNamePressed(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "一鍵留名", message: "確定?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction.init(title: "55", style: .destructive, handler: {
            _ in
            HKGaldenAPI.shared.reply(topicID: self.threadID!, content: self.keychain.get("LeaveNameText")!.replacingOccurrences(of: "\\n", with: "\n"), completion: {
                [weak self] error in
                if error == nil {
                    self?.performSegue(withIdentifier: "unwindAfterReply", sender: self)
                } else {
                    HUD.flash(.error)
                }
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
