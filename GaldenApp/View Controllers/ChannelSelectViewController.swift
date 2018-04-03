//
//  ChannelSelectViewController.swift
//  GaldenApp
//
//  Created by 1080 on 27/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift

protocol ChannelSelectViewControllerDelegate: class {
    func unwindToThreadList(channelSelected: Int)
}

class ChannelSelectViewController: UITableViewController {
    
    var channelSelected = 0
    weak var delegate: ChannelSelectViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        
        preferredContentSize = CGSize(width: 125, height: 250)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ChannelListTableViewCell.self, forCellReuseIdentifier: "ChannelListTableViewCell")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HKGaldenAPI.shared.chList!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelListTableViewCell") as! ChannelListTableViewCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(hexRGB: HKGaldenAPI.shared.chList![indexPath.row]["color"].stringValue)
        cell.selectedBackgroundView = bgColorView
        let text = HKGaldenAPI.shared.chList![indexPath.row]["name"].stringValue
        cell.channelTitle.text = text
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChannelListTableViewCell
        cell.channelTitle.textColor = .white
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChannelListTableViewCell
        cell.channelTitle.textColor = .white
        channelSelected = indexPath.row
        self.delegate?.unwindToThreadList(channelSelected: channelSelected)
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChannelListTableViewCell
        cell.channelTitle.textColor = .darkGray
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
