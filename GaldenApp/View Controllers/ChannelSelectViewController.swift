//
//  ChannelSelectViewController.swift
//  GaldenApp
//
//  Created by 1080 on 27/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift
import SideMenu

class ChannelSelectViewController: UITableViewController {
    
    var channelSelected = ""
    let cellIdentifiers: [String] = ["bw","et","ca","fn","gm","ap","it","mp","sp","lv","sy","ed","tm","tr","an","to","mu","vi","dc","st","ts","mb","ia","ac","ep"]
    let channelTitle: [String] = ["吹水臺","娛樂臺","時事臺","財經臺","遊戲臺","App臺","科技臺","電話臺","體育臺","感情臺","講故臺","飲食臺","番茄臺","旅遊臺","動漫臺","玩具臺","音樂臺","影視臺","攝影臺","學術臺","汽車臺","站務臺","內務臺","活動臺","創意臺"]
    let api = HKGaldenAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellIdentifiers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelListTableViewCell") as! ChannelListTableViewCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = api.channelColorFunc(ch: cellIdentifiers[indexPath.row])
        cell.selectedBackgroundView = bgColorView
        DispatchQueue.global(qos: .default).async {
            let image = UIImage(named: self.cellIdentifiers[indexPath.row])
            let text = self.channelTitle[indexPath.row]
            DispatchQueue.main.async {
                cell.channelIcon.image = image
                cell.channelTitle.text = text
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        channelSelected = cellIdentifiers[indexPath.row]
        performSegue(withIdentifier: "unwindToThreadList", sender: self)
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
