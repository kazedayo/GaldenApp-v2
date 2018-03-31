//
//  WelcomeViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 30/3/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    let welcomeLabel = UILabel()
    let nextButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        welcomeLabel.text = "歡迎使用\n1080-SIGNAL"
        welcomeLabel.textColor = .white
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont.systemFont(ofSize: 25)
        welcomeLabel.numberOfLines = 0
        view.addSubview(welcomeLabel)
        
        nextButton.hero.id = "button"
        nextButton.layer.cornerRadius = 5
        nextButton.backgroundColor = UIColor(rgb: 0x0076ff)
        nextButton.setTitle("繼續", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        view.addSubview(nextButton)
        
        welcomeLabel.snp.makeConstraints {
            (make) -> Void in
            make.center.equalToSuperview()
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
        }
        
        nextButton.snp.makeConstraints {
            (make) -> Void in
            make.height.equalTo(30)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.bottom.equalTo(-25)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func nextButtonPressed() {
        present(EULAViewController(), animated: true, completion: nil)
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
