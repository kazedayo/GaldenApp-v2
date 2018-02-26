//
//  ContentMenuViewController.swift
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
    var shareContent: String?
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
            upvoteButton.alpha = 0.5
            downvoteButton.isEnabled = false
            downvoteButton.alpha = 0.5
        }
        upvoteButton.setTitle("正皮: \(upvote)", for: .normal)
        downvoteButton.setTitle("負皮: \(downvote)", for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        self.shareContent = self.threadTitle! + " // by: " + self.opName! + "\nShared via 1080-SIGNAL \nhttps://hkgalden.com/view/" + self.threadID!
        performSegue(withIdentifier: "share", sender: self)
    }
    
    @IBAction func upvoteButtonPressed(_ sender: UIButton) {
        HKGaldenAPI.shared.rate(threadID: threadID!, rate: "g", completion: {
            self.upvote += 1
            self.upvoteButton.setTitle("正皮: \(self.upvote)", for: .normal)
            self.upvoteButton.isEnabled = false
            self.upvoteButton.alpha = 0.5
            self.downvoteButton.isEnabled = false
            self.downvoteButton.alpha = 0.5
        })
    }
    
    @IBAction func downvoteButtonPressed(_ sender: UIButton) {
        HKGaldenAPI.shared.rate(threadID: threadID!, rate: "b", completion: {
            self.downvote += 1
            self.downvoteButton.setTitle("負皮: \(self.downvote)", for: .normal)
            self.upvoteButton.isEnabled = false
            self.upvoteButton.alpha = 0.5
            self.downvoteButton.isEnabled = false
            self.downvoteButton.alpha = 0.5
        })
    }
    
    @IBAction func leaveNamePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "lm", sender: self)
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
