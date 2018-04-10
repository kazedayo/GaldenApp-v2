//
//  ChannelSelectViewController.swift
//  GaldenApp
//
//  Created by 1080 on 27/9/2017.
//  Copyright © 2017年 1080@galden. All rights reserved.
//

import UIKit
import KeychainSwift

class ChannelSelectViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var channelSelected = 0
    var mainVC: ThreadListViewController?
    let tableView = UITableView()
    let backgroundView = UIView()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.selectRow(at: IndexPath.init(row: channelSelected, section: 0), animated: true, scrollPosition: .top)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        backgroundView.layer.cornerRadius = 10
        backgroundView.hero.modifiers = [.position(CGPoint(x: view.frame.midX, y: 1000))]
        view.addSubview(backgroundView)
        
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ChannelListTableViewCell.self, forCellReuseIdentifier: "ChannelListTableViewCell")
        backgroundView.addSubview(tableView)
        
        backgroundView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-15)
            make.height.equalTo(200)
        }
        
        tableView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HKGaldenAPI.shared.chList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelListTableViewCell") as! ChannelListTableViewCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(hexRGB: HKGaldenAPI.shared.chList![indexPath.row]["color"].stringValue)
        cell.selectedBackgroundView = bgColorView
        let text = HKGaldenAPI.shared.chList![indexPath.row]["name"].stringValue
        cell.channelTitle.text = text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChannelListTableViewCell
        cell.channelTitle.textColor = .white
        channelSelected = indexPath.row
        mainVC?.unwindToThreadList(channelSelected: channelSelected)
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
