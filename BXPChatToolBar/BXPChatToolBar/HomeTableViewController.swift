//
//  HomeTableViewController.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/2/21.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    let chatList = ["隔壁老王", "楼下老李", "身边老向"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "主页"
        view.backgroundColor = UIColor.white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        let chatName = chatList[indexPath.row]
        
        cell.textLabel?.text = chatName

        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatName = chatList[indexPath.row]
        
        let chatViewController = BXPChatViewController()
        chatViewController.title = chatName
        
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }

}
