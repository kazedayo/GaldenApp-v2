//
//  LaunchViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 1/4/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import Kingfisher
import Apollo
import SwiftEntryKit

class LaunchViewController: UIViewController {
    
    let logo = UIImageView()
    let text = UILabel()
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if presentedViewController != nil {
            // Unsure why WKWebView calls this controller - instead of it's own parent controller
            presentedViewController?.present(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        logo.image = UIImage(named: "LaunchScreen")
        view.addSubview(logo)
        
        text.textColor = .lightGray
        text.font = UIFont.systemFont(ofSize: 17)
        text.text = "by 1080@galden"
        view.addSubview(text)
        
        logo.snp.makeConstraints {
            (make) -> Void in
            make.center.equalToSuperview()
            make.width.equalTo(128)
            make.height.equalTo(128)
        }
        
        text.snp.makeConstraints {
            (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(100)
        }
        
        if keychain.get("firstLaunch") == nil {
            let eulatTextView = UITextView()
            eulatTextView.isEditable = false
            eulatTextView.clipsToBounds = true
            eulatTextView.backgroundColor = .clear
            eulatTextView.textColor = UIColor(hexRGB: "aaaaaa")
            eulatTextView.font = UIFont.preferredFont(forTextStyle: .subheadline)
            eulatTextView.adjustsFontForContentSizeCategory = true
            eulatTextView.text = try! String(contentsOfFile: Bundle.main.path(forResource: "eula", ofType: "txt")!)
            keychain.set(false, forKey: "firstLaunch")
            let attributes = EntryAttributes.shared.loginEntry()
            SwiftEntryKit.display(entry: eulatTextView, using: attributes)
        }
        
        if keychain.get("userKey") != nil {
            let getSessionUserQuery = GetSessionUserQuery()
            apollo.fetch(query: getSessionUserQuery,cachePolicy: .fetchIgnoringCacheData) {
                [weak self] result,error in
                if error == nil {
                    if result?.data?.sessionUser == nil {
                        keychain.delete("userKey")
                        //reconfigure apollo
                        apollo = Configurations.shared.configureApollo()
                    } else {
                        sessionUser = result?.data?.sessionUser
                    }
                    let tabBarController = Configurations.shared.configureUI()
                    self?.present(tabBarController, animated: true, completion: nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                let tabBarController = Configurations.shared.configureUI()
                self.present(tabBarController, animated: true, completion: nil)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
