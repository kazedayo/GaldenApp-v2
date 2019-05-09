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
    private var shadowImageView: UIImageView?
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
        logo.tintColor = .darkGray
        view.addSubview(logo)
        
        logo.snp.makeConstraints {
            (make) -> Void in
            make.center.equalToSuperview()
            make.width.equalTo(128)
            make.height.equalTo(128)
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
                    self?.initControllers()
                }
            }
        } else {
            initControllers()
        }
    }
    
    func initControllers() {
        let tabBarController = UITabBarController()
        tabBarController.extendedLayoutIncludesOpaqueBars = true
        let threadListViewController = ThreadListViewController()
        let settingsTableViewController = SettingsTableViewController.init(style: .grouped)
        let sessionUserViewController = SessionUserViewController()
        let loginViewController = LoginViewController()
        threadListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "posts"), tag: 0)
        sessionUserViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "user"), tag: 1)
        settingsTableViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "settings"), tag: 2)
        loginViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "user"), tag: 1)
        if keychain.get("userKey") != nil {
            let controllers = [threadListViewController,sessionUserViewController,settingsTableViewController]
            tabBarController.viewControllers = controllers
        } else {
            let controllers = [threadListViewController,loginViewController,settingsTableViewController]
            tabBarController.viewControllers = controllers
        }
        let tabbaritems = tabBarController.tabBar.items!
        for item in tabbaritems {
            item.imageInsets = UIEdgeInsets.init(top: 6, left: 0, bottom: -6, right: 0)
        }
        let navVC = UINavigationController(rootViewController: tabBarController)
        navVC.navigationBar.prefersLargeTitles = true
        let splitViewController = UISplitViewController()
        let dummyVC = UINavigationController()
        dummyVC.view.backgroundColor = UIColor(white:0.1,alpha:1)
        dummyVC.navigationBar.barTintColor = UIColor(white: 0.1,alpha: 1)
        dummyVC.navigationBar.setBackgroundImage(UIImage(), for: .default)
        dummyVC.navigationBar.shadowImage = UIImage()
        dummyVC.navigationItem.largeTitleDisplayMode = .never
        splitViewController.delegate = self
        splitViewController.view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        splitViewController.viewControllers = [navVC,dummyVC]
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.hero.isEnabled = true
        splitViewController.hero.modalAnimationType = .zoom
        present(splitViewController, animated: true, completion: {
            //hacky fix
            splitViewController.view.subviews.first?.removeFromSuperview()
        })
    }
    
}
