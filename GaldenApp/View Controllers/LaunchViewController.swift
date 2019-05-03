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

class LaunchViewController: UIViewController,UISplitViewControllerDelegate {
    
    let logo = UIImageView()
    let text = UILabel()
    
    /*override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if presentedViewController != nil {
            // Unsure why WKWebView calls this controller - instead of it's own parent controller
            presentedViewController?.present(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }*/

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
        
        DispatchQueue.main.asyncAfter(deadline: 1, execute: {
            if keychain.get("firstLaunch") == nil {
                let eulatTextView = UITextView()
                eulatTextView.isEditable = false
                eulatTextView.clipsToBounds = true
                eulatTextView.backgroundColor = UIColor(white: 0.15, alpha: 1)
                eulatTextView.textColor = UIColor(hexRGB: "aaaaaa")
                eulatTextView.font = UIFont.preferredFont(forTextStyle: .body)
                eulatTextView.adjustsFontForContentSizeCategory = true
                eulatTextView.text = try! String(contentsOfFile: Bundle.main.path(forResource: "eula", ofType: "txt")!)
                let modalVC = UIViewController()
                let modalNav = UINavigationController(rootViewController: modalVC)
                modalVC.view = eulatTextView
                modalNav.modalPresentationStyle = .formSheet
                modalVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "同意並繼續", style: .done, target: self, action: #selector(self.dismissVC))
                self.present(modalNav, animated: true, completion: nil)
            } else {
                self.initViews()
            }
        })
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
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    @objc func dismissVC() {
        keychain.set(false, forKey: "firstLaunch")
        dismiss(animated: true, completion: {self.initViews()})
    }
    
    func initViews() {
        if keychain.get("userKey") != nil {
            let getSessionUserQuery = GetSessionUserQuery()
            apollo.fetch(query: getSessionUserQuery,cachePolicy: .fetchIgnoringCacheData) {
                [weak self] result,error in
                if error == nil {
                    if result?.data?.sessionUser == nil {
                        keychain.delete("userKey")
                        //reconfigure apollo
                        apollo = Configurations.shared.configureApollo()
                        let alert = UIAlertController(title: "Session Expired", message: "請重新登入　", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alert.addAction(action)
                        self?.present(alert, animated: true, completion: nil)
                    } else {
                        sessionUser = result?.data?.sessionUser
                    }
                    self?.initUI()
                }
            }
        } else {
            initUI()
        }
    }
    
    func initUI() {
        let tabBarController = Configurations.shared.configureUI()
        let navVC = UINavigationController(rootViewController: tabBarController)
        if #available(iOS 11.0, *) {
            navVC.navigationBar.prefersLargeTitles = true
        }
        navVC.hero.isEnabled = true
        navVC.hero.modalAnimationType = .zoom
        present(navVC,animated: true,completion: nil)
        /*if (UIDevice.current.userInterfaceIdiom == .phone) {
            navVC.hero.isEnabled = true
            navVC.hero.modalAnimationType = .zoom
            present(navVC,animated: true,completion: nil)
        } else if (UIDevice.current.userInterfaceIdiom == .pad) {
             let splitViewController = UISplitViewController()
             let dummyVC = UINavigationController()
             dummyVC.view.backgroundColor = UIColor(white:0.1,alpha:1)
             splitViewController.delegate = self
             splitViewController.view.backgroundColor = .darkGray
             splitViewController.viewControllers = [navVC,dummyVC]
             splitViewController.preferredDisplayMode = .allVisible
             splitViewController.hero.isEnabled = true
             splitViewController.hero.modalAnimationType = .zoom
             present(splitViewController, animated: true, completion: {
             //hacky fix
             splitViewController.view.subviews.first?.removeFromSuperview()
             })
        }*/
    }
    
}
