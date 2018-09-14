//
//  UserViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 24/7/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift

class UserViewController: UIViewController {

    let keychain = KeychainSwift()
    let logoutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        self.title = "會員資料"
        
        logoutButton.setTitle("登出", for: .normal)
        logoutButton.backgroundColor = .red
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        logoutButton.snp.makeConstraints {
            (make) -> Void in
            make.center.equalTo(view.snp.center)
            make.width.equalTo(300)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func logoutButtonPressed(_ sender: UIButton) {
        /*HKGaldenAPI.shared.logout {
            weak var pvc = self.presentingViewController
            self.keychain.delete("isLoggedIn")
            self.dismiss(animated: true, completion: {
                pvc?.present(FirstLoginViewController(), animated: true, completion: nil)
            })
        }*/
    }
    
}
