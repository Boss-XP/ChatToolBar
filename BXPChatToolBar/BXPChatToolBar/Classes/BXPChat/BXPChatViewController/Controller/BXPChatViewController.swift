//
//  BXPChatViewController.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/5.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

class BXPChatViewController: UIViewController, BXPChatToolBarDataSource {

    var messageList: [BXPChatMessageModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        view.backgroundColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0)
        view.addSubview(tableView)
        
        view.backgroundColor = UIColor.gray
        
        let chatToolBar = BXPChatToolBar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 49, width: UIScreen.main.bounds.size.width, height: 49), style: BXPChatToolBar.BXPChatToolBarStyle.defaults)

        chatToolBar.dataSource = self
        view.addSubview(chatToolBar)

        let model1 = BXPChatMessageModel()
        model1.type = BXPChatMessageModelType.text
        model1.text = NSAttributedString(string: "我就是his时间反馈登记缴费多少时间法律会计师附件案件来看")
        model1.isMine = false
        
        let model2 = BXPChatMessageModel()
        model2.type = BXPChatMessageModelType.text
        model2.text = NSAttributedString(string: "这是右边的一些数据---------------")
        model2.isMine = true
        
        messageList.append(model1)// += model1
        messageList.append(model2)
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    lazy var tableView: UITableView = {
        let tempTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.height - 49))
        tempTableView.delegate = self
        tempTableView.dataSource = self
        tempTableView.backgroundColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0)
        tempTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        tempTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        tempTableView.register(BXPChatMessageCell.self, forCellReuseIdentifier: "cell.ID.left")
        tempTableView.register(BXPChatMessageCell.self, forCellReuseIdentifier: "cell.ID.right")
        return tempTableView
    }()
    
    
    
    // MARK: - BXPChatToolBarDataSource
    func chatToolBarSendTextMessage(_ chatToolBar: BXPChatToolBar, attributeString: NSAttributedString) {
        print("--发送文字信息--富文本=\(attributeString)")
        
        let model = BXPChatMessageModel()
        model.type = BXPChatMessageModelType.text
        model.isMine = true
        model.text = attributeString
        
        messageList.append(model)
        tableView.reloadData()
    }

    func chatToolBarSendVoiceMessage(_ chatToolBar: BXPChatToolBar, voicePath: String, duration: TimeInterval) {
        print("--发送语音信息--语音文件位置=\(voicePath)--语音时长=\(Int(duration + 0.5))秒")
    }
    
    func chatToolBarSendImageMessage(_ chatToolBar: BXPChatToolBar, image: UIImage, thumbImage: UIImage, isOriginal: Bool) {
       
        print("--发送图片信息--图片=\(image)--缩略图=\(thumbImage)--是否发送原图=\(isOriginal)")
    }
    
    func chatToolBarSendVideoMessage(_ chatToolBar: BXPChatToolBar, videoPath: String, duration: TimeInterval, thumbImage: UIImage) {
        print("--发送视频信息--视频地址=\(videoPath)--视频截图=\(thumbImage)--视频时长=%.2f", duration)
    }

}


extension BXPChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = messageList[indexPath.row] as BXPChatMessageModel
        
        let identen = model.isMine ? "cell.ID.right" : "cell.ID.left"
        let cell = tableView.dequeueReusableCell(withIdentifier: identen) as! BXPChatMessageCell
        
        if model.isMine {
            cell.setRightMessageText(attributeString: model.text!, width: 0)
        } else {
            cell.setLeftMessageText(attributeString: model.text!, width: 0)
        }
        
        return cell
    }
    
    func chatToolBarShouldChangeFrameWithInputEvents(_ chatToolBar: BXPChatToolBar, estimatedFrame: CGRect, currentFrame: CGRect, duration: CGFloat) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    
}
