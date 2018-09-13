//
//  SideMenuViewController.swift
//  GaldenApp
//
//  Created by 1080 on 27/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift
import SideMenu
import Apollo

class SideMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var channelSelectedTags: [TagDetails]?
    var channels: [ChannelDetails]!
    var mainVC: ThreadListViewController?
    var firstloaded: Bool = false
    let tableView = UITableView()
    let keychain = KeychainSwift()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstloaded == false {
            tableView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: .top)
            firstloaded = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ChannelListTableViewCell.self, forCellReuseIdentifier: "ChannelListTableViewCell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(view.snp.topMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        
        let getChannelListQuery = GetChannelListQuery()
        apollo.fetch(query: getChannelListQuery) {
            [weak self] result, error in
            guard let channels = result?.data?.channels else { return }
            self?.channels = channels.map {$0.fragments.channelDetails}
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelListTableViewCell") as! ChannelListTableViewCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(white: 0.25, alpha: 1)
        cell.selectedBackgroundView = bgColorView
        let text = self.channels[indexPath.row].name
        cell.channelTitle.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChannelListTableViewCell
        cell.channelTitle.textColor = .white
        if indexPath.row == 0 {
            self.channelSelectedTags = []
        } else {
            self.channelSelectedTags = self.channels[indexPath.row].tags.map {$0.fragments.tagDetails}
        }
        mainVC?.unwindToThreadList(channel: self.channels[indexPath.row], tags: self.channelSelectedTags!)
        dismiss(animated: true, completion: nil)
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
