//
//  LaunchViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 1/4/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    let logo = UIImageView()
    let text = UILabel()

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
            make.centerY.equalToSuperview().offset(200)
        }
        
        HKGaldenAPI.shared.getChannelList(completion: {
            let mainVC = UINavigationController(rootViewController: ThreadListViewController())
            mainVC.hero.isEnabled = true
            mainVC.hero.modalAnimationType = .zoom
            self.present(mainVC, animated: true, completion: nil)
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

}
