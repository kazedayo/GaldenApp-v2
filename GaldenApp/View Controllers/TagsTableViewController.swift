//
//  TagsTableViewController.swift
//  GaldenApp
//
//  Created by Kin Wa Lam on 6/10/2018.
//  Copyright © 2018 1080@galden. All rights reserved.
//

import UIKit
import SwiftEntryKit

class TagsTableViewController: UITableViewController {

    var channels = [ChannelDetails]()
    var composeVC: ThreadComposeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.clipsToBounds = true
        tableView.separatorColor = .separator
        tableView.register(TagsTableViewCell.self, forCellReuseIdentifier: "TagsTableViewCell")
        let getChannelListQuery = GetChannelListQuery()
        apollo.fetch(query: getChannelListQuery) {
            [weak self] result,error in
            self?.channels = (result?.data?.channels.map {$0.fragments.channelDetails})!
            self?.tableView.reloadData()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return channels.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels[section].tags.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
        titleLabel.clipsToBounds = true
        titleLabel.text = channels[section].name
        titleLabel.textColor = .lightGray
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .clear
        return titleLabel
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TagsTableViewCell", for: indexPath)
        if cell == nil {
            cell = TagsTableViewCell.init(style: .default, reuseIdentifier: "TagsTableViewCell")
        }
        // Configure the cell...
        cell.textLabel!.text = "\(channels[indexPath.section].tags[indexPath.row].fragments.tagDetails.name)"
        let colorCode = channels[indexPath.section].tags[indexPath.row].fragments.tagDetails.color
        cell.textLabel!.textColor = UIColor(hexRGB: colorCode)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tagName = channels[indexPath.section].tags[indexPath.row].fragments.tagDetails.name
        let tagID = channels[indexPath.section].tags[indexPath.row].fragments.tagDetails.id
        let tagColor = channels[indexPath.section].tags[indexPath.row].fragments.tagDetails.color
        composeVC.unwindToCompose(tagName: tagName, tagID: tagID, tagColor: tagColor)
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
