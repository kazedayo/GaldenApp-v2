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
    var rated: Bool = false
    var threadTitle: String?
    var opName: String?
    var threadID: String?
    var shareContent: String?
    var mainVC: ContentViewController?
    
    let upvoteButton = UIButton()
    let downvoteButton = UIButton()
    let lmButton = UIButton()
    let shareButton = UIButton()
    let backgroundView = UIView()
    
    let keychain = KeychainSwift()
    
    lazy var swipeToDismiss = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    var backgroundViewOriginalPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        upvoteButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        upvoteButton.setTitleColor(UIColor(rgb:0x00cc33), for: .normal)
        upvoteButton.addTarget(self, action: #selector(upvoteButtonPressed(_:)), for: .touchUpInside)
        
        downvoteButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        downvoteButton.setTitleColor(UIColor(rgb: 0xfc3158), for: .normal)
        downvoteButton.addTarget(self, action: #selector(downvoteButtonPressed(_:)), for: .touchUpInside)
        
        lmButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        lmButton.setTitleColor(.white, for: .normal)
        lmButton.setTitle("一鍵留名", for: .normal)
        lmButton.addTarget(self, action: #selector(leaveNamePressed(_:)), for: .touchUpInside)
        
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.setTitle("些牙", for: .normal)
        shareButton.addTarget(self, action: #selector(shareButtonPressed(_:)), for: .touchUpInside)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.addArrangedSubview(upvoteButton)
        stackView.addArrangedSubview(downvoteButton)
        stackView.addArrangedSubview(lmButton)
        stackView.addArrangedSubview(shareButton)
        backgroundView.addSubview(stackView)
        
        backgroundView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-15)
            make.height.equalTo(200)
        }
        
        stackView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(15)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-15)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if keychain.get("LeaveNameText") == "" {
            lmButton.isHidden = true
        }
        if rated == true {
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
    
    @objc func shareButtonPressed(_ sender: Any) {
        self.shareContent = self.threadTitle! + " // by: " + self.opName! + "\nShared via 1080-SIGNAL \nhttps://hkgalden.com/view/" + self.threadID!
        dismiss(animated: true, completion: nil)
        mainVC?.share(shareContent: self.shareContent!)
    }
    
    @objc func upvoteButtonPressed(_ sender: UIButton) {
        HKGaldenAPI.shared.rate(threadID: threadID!, rate: "g", completion: {
            self.upvote += 1
            self.upvoteButton.setTitle("正皮: \(self.upvote)", for: .normal)
            self.upvoteButton.isEnabled = false
            self.upvoteButton.alpha = 0.5
            self.downvoteButton.isEnabled = false
            self.downvoteButton.alpha = 0.5
        })
    }
    
    @objc func downvoteButtonPressed(_ sender: UIButton) {
        HKGaldenAPI.shared.rate(threadID: threadID!, rate: "b", completion: {
            self.downvote += 1
            self.downvoteButton.setTitle("負皮: \(self.downvote)", for: .normal)
            self.upvoteButton.isEnabled = false
            self.upvoteButton.alpha = 0.5
            self.downvoteButton.isEnabled = false
            self.downvoteButton.alpha = 0.5
        })
    }
    
    @objc func leaveNamePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        mainVC?.lm()
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
