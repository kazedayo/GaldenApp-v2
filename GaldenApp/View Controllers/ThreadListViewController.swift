//
//  ThreadListViewController.swift
//  
//
//  Created by Kin Wa Lam on 7/10/2017.
//

import UIKit
import PKHUD
import QuartzCore
import SideMenu
import RealmSwift
import SwiftEntryKit
import SwiftDate
import Apollo

class ThreadListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate {
    
    //MARK: Properties
    var threads: [Thread] = []
    var channelId: String = "bw"
    var pageNow: Int = 1
    var pageCount: Double?
    var selectedThread: Int?
    var selectedPage: Int?
    var selectedThreadTitle: String!
    var eof = false
    
    let realm = try! Realm()
    let tableView = UITableView()
    let sideMenuVC = SideMenuViewController()
    lazy var longPress = UILongPressGestureRecognizer(target: self, action: #selector(jumpToPage(_:)))
    lazy var sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu"),style: .plain, target: self, action: #selector(channelButtonPressed(sender:)))
    lazy var newThread = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newThreadButtonPressed))
    
    var reloadButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: sideMenuVC)
        sideMenuVC.mainVC = self
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view, forMenu: .left)
        SideMenuManager.default.menuPushStyle = .subMenu
        SideMenuManager.default.menuWidth = 150
        SideMenuManager.default.menuFadeStatusBar = false
        
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .automatic
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = true
        }
        tableView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 0)
        tableView.separatorColor = UIColor(white: 0.10, alpha: 1)
        //tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ThreadListTableViewCell.classForCoder(), forCellReuseIdentifier: "ThreadListTableViewCell")
        tableView.addGestureRecognizer(longPress)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            (make) -> Void in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl: )), for: .valueChanged)
        refreshControl.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tableView.refreshControl = refreshControl
        
        reloadButton.center = self.view.center
        reloadButton.setTitle("重新載入", for: .normal)
        reloadButton.isHidden = true
        reloadButton.addTarget(self, action: #selector(reloadButtonPressed(_:)), for: .touchUpInside)
        updateSequence(append: false, completion: {})
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        pageNow = 1
        DispatchQueue.main.asyncAfter(deadline: 0.3, execute: {
            self.updateSequence(append: false, completion: {
                refreshControl.endRefreshing()
            })
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.navigationItem.leftBarButtonItem = sideMenuButton
        tabBarController?.navigationItem.rightBarButtonItem = newThread
        tabBarController?.navigationItem.title = "吹水臺"
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath != nil {
            tableView.deselectRow(at: indexPath!, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return threads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadListTableViewCell") as! ThreadListTableViewCell
        cell.threadTitleLabel.text = threads[indexPath.row].title
        cell.detailLabel.text = "\(threads[indexPath.row].nickName) // \(threads[indexPath.row].count)回覆 // \(threads[indexPath.row].date)"
        cell.newReplyLabel.text = threads[indexPath.row].newReplyCount
        cell.tagLabel.text = "#\(threads[indexPath.row].tagName)"
        cell.tagLabel.textColor = UIColor(hexRGB: threads[indexPath.row].tagColor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let cell = tableView.cellForRow(at: indexPath) as! ThreadListTableViewCell
            cell.newReplyLabel.text = ""
            cell.setNeedsLayout()
            let contentVC = ContentViewController()
            let contentNav = UINavigationController(rootViewController: contentVC)
            let selectedThread = self.threads[indexPath.row].id
            contentVC.tID = selectedThread
            contentVC.title = self.threads[indexPath.row].title
            contentVC.sender = "cell"
            self.splitViewController?.showDetailViewController(contentNav, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (threads.count - indexPath.row) == 5 {
            self.pageNow += 1
            self.updateSequence(append: true, completion: {})
        }
    }
    
    @objc func jumpToPage(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                self.selectedThread = threads[indexPath.row].id
                self.selectedThreadTitle = threads[indexPath.row].title
                self.pageCount = ceil((Double(threads[indexPath.row].count))/50)
                let pageVC = PageSelectViewController()
                pageVC.pageCount = self.pageCount!
                pageVC.titleText = self.selectedThreadTitle
                pageVC.mainVC = self
                SwiftEntryKit.display(entry: pageVC, using: EntryAttributes.shared.centerEntryZoom())
            }
        }
    }
    
    @objc func channelButtonPressed(sender: UIBarButtonItem) {
        sideMenuVC.mainVC = self
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @objc func newThreadButtonPressed() {
        if keychain.get("userKey") != nil {
            let composeVC = ThreadComposeViewController()
            let composeNavVC = UINavigationController(rootViewController: composeVC)
            composeVC.threadVC = self
            composeNavVC.modalPresentationStyle = .formSheet
            present(composeNavVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: nil, message: "請先登入", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            present(alert,animated: true,completion: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "pageSelect":
            
        default:
            break
        }
    }*/
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //Delegates
    func unwindToThreadList(channel: ChannelDetails) {
        self.channelId = channel.id
        self.pageNow = 1
        self.navigationItem.title = channel.name
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        self.updateSequence(append: false, completion: {})
    }
    
    func unwindToThreadListAfterNewPost() {
        self.updateSequence(append: false, completion: {})
    }
    
    func unwindAfterPageSelect(pageSelected: Int) {
        self.selectedPage = pageSelected
        DispatchQueue.main.async {
            let contentVC = ContentViewController()
            let contentNav = UINavigationController(rootViewController: contentVC)
            contentVC.tID = self.selectedThread
            contentVC.title = self.selectedThreadTitle
            contentVC.pageNow = self.selectedPage!
            //contentVC.hidesBottomBarWhenPushed = true
            //self.navigationController?.pushViewController(contentVC, animated: true)
            self.splitViewController?.showDetailViewController(contentNav, sender: self)
        }
    }
    
    @objc func reloadButtonPressed(_ sender: UIButton) {
        self.updateSequence(append: false, completion: {})
    }
    
    private func updateSequence(append: Bool, completion: @escaping ()->Void) {
        let getThreadsQuery = GetThreadsQuery(id: channelId, page: pageNow)
        NetworkActivityIndicatorManager.networkOperationStarted()
        apollo.fetch(query: getThreadsQuery,cachePolicy: .fetchIgnoringCacheData) {
            [weak self] result, error in
            if (error == nil) {
                var threads = result?.data?.threadsByChannel.map {$0.fragments.threadListDetails}
                if threads?.isEmpty ?? true {
                    self?.eof = true
                    completion()
                }
                if keychain.get("userKey") != nil {
                    let blockedUserIds = sessionUser?.blockedUserIds
                    threads = (threads!.filter {!(blockedUserIds?.contains($0.replies[0].author.id))!})
                } else {
                    //review no tomato
                    threads = (threads!.filter {$0.tags[0].fragments.tagDetails.id != "PVAy33AYm"})
                }
                //convert to thread object
                for thread in threads! {
                    self?.threads.append(Thread.init(id: thread.id,title: thread.title, nick: thread.replies.map {$0.authorNickname}.first!, count: thread.totalReplies, date: thread.replies.map {$0.date}.last!, tag: thread.tags.map {$0.fragments.tagDetails}.first!.name, tagC: thread.tags.map {$0.fragments.tagDetails}.first!.color))
                }
                self?.tableView.reloadData()
                self?.reloadButton.isHidden = true
                self?.tableView.isHidden = false
            } else {
                self?.reloadButton.isHidden = false
            }
            NetworkActivityIndicatorManager.networkOperationFinished()
            completion()
        }
    }
    
}
