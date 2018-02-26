//
//  UserDetailViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 19/10/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift
import PKHUD
import RealmSwift

class UserDetailViewController: UIViewController,UINavigationControllerDelegate,UITextViewDelegate,UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var leaveNameTextView: UITextView!
    @IBOutlet weak var userID: UILabel!
    
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loggedIn()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        leaveNameTextView.endEditing(true)
        keychain.set(leaveNameTextView.text!, forKey: "LeaveNameText")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        if segue.identifier == ("detailPop") {
            let popoverViewController = segue.destination as! UserDetailPopoverViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.popoverPresentationController!.permittedArrowDirections = .init(rawValue: 0)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        HKGaldenAPI.shared.logout {
            weak var pvc = self.presentingViewController
            self.keychain.delete("isLoggedIn")
            self.dismiss(animated: true, completion: {
                pvc?.performSegue(withIdentifier: "logoutSegue", sender: pvc)
            })
        }
    }
    
    func loggedIn() {
        userName.text = keychain.get("userName")!
        userID.text = keychain.get("userID")!
        leaveNameTextView.text = keychain.get("LeaveNameText")
    }
    
    @IBAction func unwindFromPop(segue: UIStoryboardSegue) {
        self.loggedIn()
    }
}
