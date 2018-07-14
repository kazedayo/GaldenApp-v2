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

class SideMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var channelSelected = 0
    var mainVC: ThreadListViewController?
    let tableView = UITableView()
    let userName = UILabel()
    let userID = UILabel()
    let logoutButton = UIButton()
    let settingsButton = UIButton()
    let titleButton = UIButton()
    let keychain = KeychainSwift()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.selectRow(at: IndexPath.init(row: channelSelected, section: 0), animated: true, scrollPosition: .top)
        HKGaldenAPI.shared.getUserDetail(completion: {
            uname, uid in
            self.userName.text = uname
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ChannelListTableViewCell.self, forCellReuseIdentifier: "ChannelListTableViewCell")
        view.addSubview(tableView)
        
        titleButton.setImage(UIImage(named: "menuIcon"), for: .normal)
        titleButton.setTitle("  1080-SIGNAL", for: .normal)
        titleButton.setTitleColor(.lightGray, for: .normal)
        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        titleButton.isUserInteractionEnabled = false
        view.addSubview(titleButton)
        
        userName.text = "撈緊..."
        userName.textColor = .white
        userName.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(userName)
        
        userID.text = keychain.get("userID")!
        userID.textColor = .lightGray
        userID.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(userID)
        
        logoutButton.setImage(UIImage(named: "logout"), for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        logoutButton.setTitle(" 登出", for: .normal)
        logoutButton.tintColor = .white
        logoutButton.imageView?.contentMode = .scaleAspectFit
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed(_:)), for: .touchUpInside)
        
        settingsButton.setImage(UIImage(named: "settings"), for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        settingsButton.setTitle(" 設定", for: .normal)
        settingsButton.tintColor = .white
        settingsButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed(_:)), for: .touchUpInside)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.addArrangedSubview(logoutButton)
        stackView.addArrangedSubview(settingsButton)
        view.addSubview(stackView)
        
        titleButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(view.snp.topMargin).offset(-33)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        userName.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(titleButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        userID.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(userName.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        stackView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(userID.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        tableView.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(stackView.snp.bottom).offset(20)
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
        if keychain.get("userID")! == "7687" && indexPath.row == 12 {
            let alert = UIAlertController(title: "#ng#", message: "you know too much", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            present(alert,animated: true,completion: nil)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! ChannelListTableViewCell
            cell.channelTitle.textColor = .white
            channelSelected = indexPath.row
            mainVC?.unwindToThreadList(channelSelected: channelSelected)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func logoutButtonPressed(_ sender: UIButton) {
        HKGaldenAPI.shared.logout {
            weak var pvc = self.presentingViewController
            self.keychain.delete("isLoggedIn")
            self.dismiss(animated: true, completion: {
                pvc?.present(FirstLoginViewController(), animated: true, completion: nil)
            })
        }
    }
    
    @objc func settingsButtonPressed(_ sender: UIButton) {
        let settingsVC = SettingsViewController()
        SideMenuManager.default.menuLeftNavigationController?.pushViewController(settingsVC, animated: true)
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
