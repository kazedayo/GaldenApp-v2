//
//  ThreadListViewController.swift
//  
//
//  Created by Kin Wa Lam on 7/10/2017.
//

import UIKit
import KeychainSwift
import SideMenu
import PKHUD

class ThreadListViewController: UITableViewController,UITableViewDataSourcePrefetching {
    
    //HKGaldenAPI.swift required (NOT included in GitHub repo)
    let api: HKGaldenAPI = HKGaldenAPI()
    
    //MARK: Properties
    var threads = [ThreadList]()
    var channelNow: String?
    var pageNow: String?
    var pageCount: Double?
    var selectedThread: String!
    var blockedUsers = [String]()
    var selectedPage: Int?
    var selectedThreadTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        let menuRightNavigationController = storyboard!.instantiateViewController(withIdentifier: "RightMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
        self.tableView.tableFooterView = spinner;
        
        channelNow = "bw"
        pageNow = "1"
        self.navigationItem.title = api.channelNameFunc(ch: channelNow!)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = self.api.channelColorFunc(ch: self.channelNow!).as1ptImage()
        api.fetchThreadList(currentChannel: channelNow!, pageNumber: pageNow!, completion: {
            [weak self] threads,blocked,error in
            if (error == nil) {
                self?.threads = threads
                self?.blockedUsers = blocked
                self?.tableView.reloadData()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.shadowImage = self.api.channelColorFunc(ch: self.channelNow!).as1ptImage()
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        api.fetchThreadList(currentChannel: channelNow!, pageNumber: pageNow!, completion: {
            [weak self] threads,blocked,error in
            if (error == nil) {
                self?.threads = threads
                self?.blockedUsers = blocked
                self?.tableView.reloadData()
                refreshControl.endRefreshing()
            }
        })
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
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadListTableViewCell", for: indexPath) as! ThreadListTableViewCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        cell.selectedBackgroundView = bgColorView
        
        // Configure the cell...
        if (blockedUsers.contains(threads[indexPath.row].userID)) {
            cell.threadTitleLabel.text = "[已封鎖]"
            cell.threadTitleLabel.textColor = .darkGray
            cell.detailLabel.text = "//unknown identity//"
        } else {
            cell.threadTitleLabel.text = threads[indexPath.row].title
            cell.threadTitleLabel.textColor = .lightGray
            cell.detailLabel.text = threads[indexPath.row].userName + "  " + "回覆:" + threads[indexPath.row].count + "  " + "評分:" + threads[indexPath.row].rate
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (blockedUsers.contains(threads[indexPath.row].userID)) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title:"喂喂喂",message:"扑咗就唔好心郁郁",preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:"好囉",style:.cancel,handler:nil))
                self.present(alert,animated: true,completion: nil)
            }
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            self.performSegue(withIdentifier: "GoToPost", sender: cell)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath)
    {
        // At the bottom...
        if (indexPath.row == self.threads.count - 1) {
            pageNow = String(Int(pageNow!)! + 1)
            api.fetchThreadList(currentChannel: channelNow!, pageNumber: pageNow!, completion: {
                [weak self] threads,blocked,error in
                if (error == nil) {
                    self?.threads.append(contentsOf: threads)
                    self?.blockedUsers = blocked
                    self?.tableView.reloadData()
                }
            }) // network request to get more data
        }
    }
    
    @IBAction func jumpToPage(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
                
            let touchPoint = sender.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                self.selectedThread = threads[indexPath.row].id
                self.selectedThreadTitle = threads[indexPath.row].title
                self.pageCount = ceil(Double(threads[indexPath.row].count)!/25)
                self.performSegue(withIdentifier: "pageSelect", sender: sender)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "GoToPost":
            guard let contentViewController = segue.destination as? ContentViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            if (sender is ThreadListTableViewCell) {
                let selectedThreadCell = sender as? ThreadListTableViewCell
                let indexPath = tableView.indexPath(for: selectedThreadCell!)
                let selectedThread = threads[(indexPath?.row)!].id
                contentViewController.threadIdReceived = selectedThread
                contentViewController.title = threads[(indexPath?.row)!].title
            }
            else {
                contentViewController.threadIdReceived = selectedThread
                contentViewController.title = selectedThreadTitle
                contentViewController.pageNow = self.selectedPage!
            }
        case "StartNewPost":
            let destination = segue.destination as! ComposeViewController
            destination.channel = channelNow!
            destination.type = "newThread"
        case "pageSelect":
            let destination = segue.destination as! PageSelectViewController
            destination.type = "threadList"
            destination.pageCount = self.pageCount!
        default:
            break
        }
    }
    
    //Unwind Segue
    @IBAction func unwindToThreadList(segue: UIStoryboardSegue) {
        let channelSelectViewController = segue.source as! ChannelSelectViewController
        self.channelNow = channelSelectViewController.channelSelected
        self.pageNow = "1"
        self.navigationItem.title = api.channelNameFunc(ch: channelNow!)
        self.navigationController?.navigationBar.shadowImage = self.api.channelColorFunc(ch: self.channelNow!).as1ptImage()
        api.fetchThreadList(currentChannel: channelNow!, pageNumber: pageNow!, completion: {
            [weak self] threads,blocked,error in
            if (error == nil) {
                self?.threads = threads
                self?.blockedUsers = blocked
                self?.tableView.reloadData()
            }
        })
    }
    
    @IBAction func unwindToThreadListAfterNewPost(segue: UIStoryboardSegue) {
        HUD.flash(.success)
        api.fetchThreadList(currentChannel: channelNow!, pageNumber: pageNow!, completion: {
            [weak self] threads,blocked,error in
            if (error == nil) {
                self?.threads = threads
                self?.blockedUsers = blocked
                self?.tableView.reloadData()
            }
        })
    }
    
    @IBAction func unwindAfterPageSelect(segue: UIStoryboardSegue) {
        let source = segue.source as! PageSelectViewController
        self.selectedPage = source.pageSelected
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "GoToPost", sender: self)
        }
    }
}
