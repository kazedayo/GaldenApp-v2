//
//  ThreadListViewController.swift
//  
//
//  Created by Kin Wa Lam on 7/10/2017.
//

import UIKit
import KeychainSwift
import PKHUD
import GoogleMobileAds
import QuartzCore

class ThreadListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate,UIPopoverPresentationControllerDelegate {
    
    //MARK: Properties
    var threads = [ThreadList]()
    var channelNow: String = "bw"
    var pageNow: Int = 1
    var pageCount: Double?
    var selectedThread: String!
    var blockedUsers = [String]()
    var selectedPage: Int?
    var selectedThreadTitle: String!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var reloadButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        adBannerView.adUnitID = "ca-app-pub-6919429787140423/1613095078"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        self.navigationItem.title = HKGaldenAPI.shared.channelNameFunc(ch: channelNow)
        self.navigationController?.navigationBar.barTintColor = HKGaldenAPI.shared.channelColorFunc(ch: channelNow)
        self.navigationController?.navigationBar.isTranslucent = true
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .bottom)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl: )), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            tableView.addSubview(refreshControl)
        }
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
        self.tableView.tableFooterView = spinner;
        
        reloadButton.center = self.view.center
        reloadButton.setTitle("重新載入", for: .normal)
        reloadButton.isHidden = true
        reloadButton.addTarget(self, action: #selector(reloadButtonPressed(_:)), for: .touchUpInside)
        
        updateSequence(append: false, completion: {})
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        self.pageNow = 1
        DispatchQueue.main.asyncAfter(deadline: 1, execute: {
            self.updateSequence(append: false, completion: {
                refreshControl.endRefreshing()
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (adOption.adEnabled == false) {
            heightConstraint.constant = 0
            adBannerView.layoutIfNeeded()
        } else {
            adBannerView.load(GADRequest())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.barTintColor = HKGaldenAPI.shared.channelColorFunc(ch: channelNow)
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath != nil {
            tableView.deselectRow(at: indexPath!, animated: true)
        }
        if #available(iOS 11.0, *) {
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: adBannerView.frame.height, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: adBannerView.frame.height, right: 0)
        } else {
            self.tableView.contentInset = UIEdgeInsets.init(top: (navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height, left: 0, bottom: (navigationController?.toolbar.frame.height)! + adBannerView.frame.height, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.init(top: (navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height, left: 0, bottom: (navigationController?.toolbar.frame.height)! + adBannerView.frame.height, right: 0)
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        //print("Banner loaded successfully")
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            bannerView.transform = CGAffineTransform.identity
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        //print("Fail to receive ads")
        print(error)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadListTableViewCell", for: indexPath) as! ThreadListTableViewCell
        
        // Configure the cell...
            let title = self.threads[indexPath.row].title
            var uname = self.threads[indexPath.row].userName
            let count = self.threads[indexPath.row].count
            let rate = self.threads[indexPath.row].rate
            uname = uname.replacingOccurrences(of: "\n", with: "")
        if (self.blockedUsers.contains(self.threads[indexPath.row].userID)) {
            cell.threadTitleLabel.text = "[已封鎖]"
            cell.threadTitleLabel.textColor = .darkGray
            cell.detailLabel.text = "//unknown identity//"
            cell.detailLabel.textColor = .darkGray
        } else {
            cell.threadTitleLabel.text = title
            cell.threadTitleLabel.textColor = .lightGray
            cell.detailLabel.text = "\(uname) // 回覆: \(count) // 評分: \(rate)"
            cell.detailLabel.textColor = .darkGray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (blockedUsers.contains(threads[indexPath.row].userID)) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title:"喂喂喂",message:"扑咗就唔好心郁郁",preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:"好囉",style:.cancel,handler:nil))
                self.present(alert,animated: true,completion: nil)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            //tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "GoToPost", sender: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (threads.count - indexPath.row) == 1 {
            self.pageNow += 1
            DispatchQueue.main.asyncAfter(deadline: 1, execute: {
                self.updateSequence(append: true, completion: {})
            })
        }
    }
    
    @IBAction func jumpToPage(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
                
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                self.selectedThread = threads[indexPath.row].id
                self.selectedThreadTitle = threads[indexPath.row].title
                self.pageCount = ceil((Double(threads[indexPath.row].count)! + 1)/25)
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
                contentViewController.sender = "cell"
            }
            else {
                contentViewController.threadIdReceived = selectedThread
                contentViewController.title = selectedThreadTitle
                contentViewController.pageNow = self.selectedPage!
            }
        case "StartNewPost":
            let destination = segue.destination as! ComposeViewController
            destination.channel = channelNow
            destination.type = "newThread"
        case "pageSelect":
            let destination = segue.destination as! PageSelectViewController
            destination.type = "threadList"
            destination.pageCount = self.pageCount!
            destination.titleText = self.selectedThreadTitle
        case "channelSelect":
            let popoverViewController = segue.destination as! ChannelSelectViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
        default:
            break
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //Unwind Segue
    @IBAction func unwindToThreadList(segue: UIStoryboardSegue) {
        let channelSelectViewController = segue.source as! ChannelSelectViewController
        self.channelNow = channelSelectViewController.channelSelected
        self.pageNow = 1
        self.navigationItem.title = HKGaldenAPI.shared.channelNameFunc(ch: channelNow)
        self.navigationController?.navigationBar.barTintColor = HKGaldenAPI.shared.channelColorFunc(ch: channelNow)
        //self.navigationController?.navigationBar.shadowImage = HKGaldenAPI.shared.channelColorFunc(ch: self.channelNow).as1ptImage()
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        self.updateSequence(append: false, completion: {})
    }
    
    @IBAction func unwindToThreadListAfterNewPost(segue: UIStoryboardSegue) {
        HUD.flash(.success)
        self.updateSequence(append: false, completion: {})
    }
    
    @IBAction func unwindAfterPageSelect(segue: UIStoryboardSegue) {
        let source = segue.source as! PageSelectViewController
        self.selectedPage = source.pageSelected
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "GoToPost", sender: self)
        }
    }
    
    @objc func reloadButtonPressed(_ sender: UIButton) {
        self.updateSequence(append: false, completion: {})
    }
    
    private func updateSequence(append: Bool, completion: @escaping ()->Void) {
        HKGaldenAPI.shared.fetchThreadList(currentChannel: channelNow, pageNumber: String(pageNow), completion: {
            [weak self] threads,blocked,error in
            if (error == nil) {
                if append == true {
                    self?.threads.append(contentsOf: threads)
                } else {
                    self?.threads = threads
                }
                self?.blockedUsers = blocked
                self?.tableView.reloadData()
                self?.reloadButton.isHidden = true
                self?.tableView.isHidden = false
            } else {
                self?.reloadButton.isHidden = false
            }
            completion()
        })
    }
}
