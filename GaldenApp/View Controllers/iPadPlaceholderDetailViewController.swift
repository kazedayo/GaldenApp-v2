//
//  iPadPlaceholderDetailViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 19/6/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit

class iPadPlaceholderDetailViewController: UIViewController {
    let messageText = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        messageText.text = "<-係隔離揀個post :)"
        messageText.textColor = .white
        
        view.addSubview(messageText)
        
        messageText.snp.makeConstraints {
            (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20)
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

}
