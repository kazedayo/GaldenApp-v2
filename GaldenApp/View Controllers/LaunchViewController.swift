//
//  LaunchViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 1/4/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import Kingfisher

class LaunchViewController: UIViewController,UISplitViewControllerDelegate {
    
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
        
        HKGaldenAPI.shared.getChannelList(completion: {
            var splitViewController =  UISplitViewController()
            splitViewController.delegate = self
            let tabBarController = UITabBarController()
            let threadListViewController = ThreadListViewController()
            let settingsViewController = SettingsViewController()
            let userViewController = UserViewController()
            threadListViewController.tabBarItem = UITabBarItem(title: "睇post", image: UIImage(named: "posts"), tag: 0)
            userViewController.tabBarItem = UITabBarItem(title: "會員資料", image: UIImage(named: "user"), tag: 1)
            settingsViewController.tabBarItem = UITabBarItem(title: "設定", image: UIImage(named: "settings"), tag: 2)
            let controllers = [threadListViewController,userViewController,settingsViewController]
            tabBarController.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
            let detailViewController = iPadPlaceholderDetailViewController()
            splitViewController.viewControllers = [tabBarController,detailViewController]
            splitViewController.preferredDisplayMode = .allVisible
            splitViewController.hero.isEnabled = true
            splitViewController.hero.modalAnimationType = .zoom
            self.present(splitViewController, animated: true, completion: nil)
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
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
