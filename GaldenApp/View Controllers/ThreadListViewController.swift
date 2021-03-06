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
import SwiftDate
import Apollo

class ThreadListViewController: UITableViewController,UIPopoverPresentationControllerDelegate {
    
    //MARK: Properties
    var threads: [Thread] = []
    var channelId: String = "bw"
    var channelName = "吹水臺"
    var pageNow: Int = 1
    var pageCount: Double?
    var selectedThread: Int?
    var selectedPage: Int?
    var selectedThreadTitle: String!
    var eof = false
    
    let realm = try! Realm()
    let sideMenuVC = SideMenuViewController()
    //lazy var longPress = UILongPressGestureRecognizer(target: self, action: #selector(jumpToPage(_:)))
    lazy var sideMenuButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"),style: .plain, target: self, action: #selector(channelButtonPressed(sender:)))
    lazy var newThread = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),style: .plain, target: self, action: #selector(newThreadButtonPressed))
    lazy var nextPageButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
    lazy var spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.backgroundColor = .systemBackground
        tableView.separatorColor = .separator
        //tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ThreadListTableViewCell.classForCoder(), forCellReuseIdentifier: "ThreadListTableViewCell")
        //tableView.addGestureRecognizer(longPress)
        
        sideMenuVC.view.layoutSubviews()
        let menuLeftNavigationController = SideMenuNavigationController(rootViewController: sideMenuVC)
        sideMenuVC.mainVC = self
        SideMenuManager.default.leftMenuNavigationController = menuLeftNavigationController
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
        menuLeftNavigationController.pushStyle = .subMenu
        menuLeftNavigationController.menuWidth = 150
        menuLeftNavigationController.statusBarEndAlpha = 0
        menuLeftNavigationController.navigationBar.isHidden = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl: )), for: .valueChanged)
        //refreshControl.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tableView.refreshControl = refreshControl
        
        //footer for next page
        spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50)
        nextPageButton.setTitle("下一頁", for: .normal)
        nextPageButton.setTitleColor(.darkGray, for: .normal)
        nextPageButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        nextPageButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        tableView.tableFooterView = nextPageButton
        
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
        tabBarController?.navigationItem.title = channelName
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return threads.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadListTableViewCell") as! ThreadListTableViewCell
        cell.threadTitleLabel.text = threads[indexPath.row].title
        cell.detailLabel.text = "\(threads[indexPath.row].nickName) // \(threads[indexPath.row].count)回覆 // \(threads[indexPath.row].date)"
        cell.tagLabel.text = "#\(threads[indexPath.row].tagName)"
        cell.tagLabel.textColor = UIColor(hexRGB: threads[indexPath.row].tagColor)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let cell = tableView.cellForRow(at: indexPath) as! ThreadListTableViewCell
            cell.setNeedsLayout()
            let contentVC = ContentViewController()
            let contentNav = UINavigationController(rootViewController: contentVC)
            let selectedThread = self.threads[indexPath.row].id
            contentVC.tID = selectedThread
            //contentVC.title = self.threads[indexPath.row].title
            contentVC.sender = "cell"
            self.splitViewController?.showDetailViewController(contentNav, sender: self)
        }
    }
    
    @objc func nextPage() {
        spinner.startAnimating()
        self.tableView.tableFooterView = spinner;
        self.pageNow += 1
        self.updateSequence(append: true, completion: {
            self.tableView.tableFooterView = self.nextPageButton
        })
    }
    
    /*@objc func jumpToPage(_ sender: UILongPressGestureRecognizer) {
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
                pageVC.modalPresentationStyle = .popover
                pageVC.popoverPresentationController?.delegate = self
                let cell = tableView.cellForRow(at: indexPath) as! ThreadListTableViewCell
                pageVC.popoverPresentationController?.sourceView = cell.tagLabel
                pageVC.popoverPresentationController?.sourceRect = cell.tagLabel.bounds
                pageVC.popoverPresentationController?.backgroundColor = UIColor(white: 0.15, alpha: 0.5)
                pageVC.popoverPresentationController?.permittedArrowDirections = .right
                pageVC.preferredContentSize = CGSize(width: 200, height: 200)
                self.present(pageVC,animated: true,completion: nil)
            }
        }
    }*/
    
    @objc func channelButtonPressed(sender: UIBarButtonItem) {
        sideMenuVC.mainVC = self
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
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
    
    //MARK: popover delegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //Delegates
    func unwindToThreadList(channel: ChannelDetails) {
        self.channelId = channel.id
        self.pageNow = 1
        self.channelName = channel.name
        tabBarController?.navigationItem.title = channelName
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        self.tableView.isHidden = true
        self.updateSequence(append: false, completion: {
            self.tableView.isHidden = false
        })
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
            //contentVC.title = self.selectedThreadTitle
            contentVC.pageNow = self.selectedPage!
            //contentVC.hidesBottomBarWhenPushed = true
            //self.navigationController?.pushViewController(contentVC, animated: true)
            self.splitViewController?.showDetailViewController(contentNav, sender: self)
        }
    }
    
    private func updateSequence(append: Bool, completion: @escaping ()->Void) {
        let getThreadsQuery = GetThreadsQuery(id: channelId, page: pageNow)
        NetworkActivityIndicatorManager.networkOperationStarted()
        apollo.fetch(query: getThreadsQuery,cachePolicy: .fetchIgnoringCacheData) {
            [weak self] result in
            guard let data = try? result.get().data else { return }
            var threads = data.threadsByChannel.map {$0.fragments.threadListDetails}
            if threads.isEmpty {
                self?.eof = true
                completion()
            }
            if keychain.get("userKey") != nil {
                let blockedUserIds = sessionUser?.blockedUserIds
                threads = (threads.filter {!(blockedUserIds?.contains($0.replies[0].author.id))!})
            } else {
                //review no tomato
                threads = (threads.filter {$0.tags[0].fragments.tagDetails.id != "PVAy33AYm"})
            }
            //convert to thread object
            if append == false {
                self?.threads = []
            }
            for thread in threads {
                let titleTrim = thread.title.trimmingCharacters(in: .whitespacesAndNewlines)
                self?.threads.append(Thread.init(id: thread.id,title: titleTrim, nick: thread.replies.map {$0.authorNickname}.first!, count: thread.totalReplies, date: thread.replies.map {$0.date}.last!, tag: thread.tags.map {$0.fragments.tagDetails}.first!.name, tagC: thread.tags.map {$0.fragments.tagDetails}.first!.color))
            }
            self?.tableView.reloadData()
            self?.tableView.isHidden = false
            NetworkActivityIndicatorManager.networkOperationFinished()
            completion()
        }
    }
    
}
