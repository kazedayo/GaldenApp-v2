//
//  EULAViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 7/11/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import Hero

class EULAViewController: UIViewController {

    @IBOutlet weak var eulaLabel: UILabel!
    @IBOutlet weak var eulaContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eulaLabel.hero.modifiers = [.position(CGPoint(x:eulaLabel.frame.midX,y:-50))]
        eulaContent.hero.modifiers = [.fade,.scale(0.5)]
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
