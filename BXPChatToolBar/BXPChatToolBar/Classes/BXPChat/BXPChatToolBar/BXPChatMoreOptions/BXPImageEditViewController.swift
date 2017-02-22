//
//  BXPImageEditViewController.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/2/16.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

class BXPImageEditViewController: UIViewController {

    var sourceImage: UIImage?
    var footerV = UIView()
    
    var sendImageHandler: ((_ sendImage: UIImage,_ thumbImage: UIImage, _ isOriginal: Bool) -> Void)?
    
    init(image: UIImage, sendHandler: @escaping (_ sendImage: UIImage,_ thumbImage: UIImage, _ isOriginal: Bool) -> Void) {
        
        super.init(nibName: nil, bundle: nil)
        sourceImage = image;
        
        sendImageHandler = sendHandler
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() -> Void {
        view.backgroundColor = UIColor.black
        
        var frame: CGRect = CGRect.zero
        
        if ((sourceImage?.size.width)! / (sourceImage?.size.height)!) < (view.bounds.size.width / view.bounds.size.height) {
            frame.origin.y = 0
            frame.size.height = view.bounds.size.height
            frame.size.width = frame.size.height * (sourceImage?.size.width)! / (sourceImage?.size.height)!
            frame.origin.x = (view.bounds.size.width - frame.size.width) * 0.5
        } else {
            frame.origin.x = 0
            frame.size.width = view.bounds.size.width
            frame.size.height = frame.size.width * (sourceImage?.size.height)! / (sourceImage?.size.width)!
            frame.origin.y = (UIScreen.main.bounds.size.height - frame.size.height) * 0.5
        }
        
//        let imageView = UIImageView(frame: frame)
        centerImageView.frame = frame
        centerImageView.image = sourceImage
        view.addSubview(centerImageView)
        
        setupFooterView()
    }
    
    func setupFooterView() -> Void {
        
        let footerHeight: CGFloat = 44
        let footerView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - footerHeight, width: UIScreen.main.bounds.width, height: footerHeight))
        footerView.backgroundColor = UIColor.init(white: 1.0, alpha: 0.9)
        footerView.layer.borderWidth = 0.5
        footerView.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(footerView)
        footerV = footerView
        
        let originalButtonFrame = CGRect(x: 3, y: 0, width: footerHeight, height: footerHeight)
        originalSelectedButton.frame = originalButtonFrame
        footerView.addSubview(originalSelectedButton)
        
        let originalLabel = UILabel(frame: CGRect(x: footerHeight, y: 0, width: UIScreen.main.bounds.size.width, height: footerHeight))
        originalLabel.font = UIFont.systemFont(ofSize: 16)
        originalLabel.textColor = UIColor.black

        let imageDataLength = UIImagePNGRepresentation(sourceImage!)?.count
        
        var labelText: String = " "
        if (imageDataLength! / 1024) < 1024 {
            labelText = String(format: "原图(%.2fKB)", arguments: [Float(Float(imageDataLength!) / Float(1024))])
        } else {
            labelText = String(format: "原图(%.2fMB)", arguments: [Float(Float(imageDataLength!) / Float(1024) / Float(1024))])
        }
        originalLabel.text = labelText
        
        footerView.addSubview(originalLabel)
        
        let buttonWidth: CGFloat = 60
        let buttonHeight: CGFloat = 34
        let sendButtonFrame = CGRect(x: UIScreen.main.bounds.size.width - buttonWidth - 6, y: 5, width: buttonWidth, height: buttonHeight)
        sendButton.frame = sendButtonFrame
        footerView.addSubview(sendButton)
        let cancelButtonFrame = CGRect(x: UIScreen.main.bounds.size.width - buttonWidth - 6 - buttonWidth, y: 5, width: buttonWidth, height: buttonHeight)
        cancelButton.frame = cancelButtonFrame
        footerView.addSubview(cancelButton)
 
    }
    
    // MARK: - utility
    func getThumbImage() -> UIImage {
        UIGraphicsBeginImageContext(centerImageView.bounds.size)
        sourceImage?.draw(in: centerImageView.bounds)
        let getImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return getImage!
    }
    
    // MARK: - Getter
    lazy var centerImageView: UIImageView = {
        let tempView = UIImageView()
        return tempView
    }()
    
    lazy var originalSelectedButton: UIButton = {
        let tempButton = UIButton()
        let buttonPading: CGFloat = 12
        tempButton.imageEdgeInsets = UIEdgeInsetsMake(buttonPading, buttonPading, buttonPading, buttonPading)
        tempButton.setImage(UIImage(named: "check_unselected"), for: UIControlState.normal)
        tempButton.setImage(UIImage(named: "check_selected"), for: UIControlState.selected)
        
        tempButton.addTarget(self, action: #selector(self.originalSelectedButtonClicked(button:)), for: UIControlEvents.touchUpInside)
        return tempButton
    }()
    
    lazy var sendButton: UIButton = {
        let tempButton = UIButton()

        tempButton.setTitle("发送", for: UIControlState.normal)
        tempButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        tempButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        tempButton.backgroundColor = UIColor(red: 0, green: 198/255, blue: 129/255, alpha: 1.0)
        tempButton.layer.cornerRadius = 5
        tempButton.layer.masksToBounds = true
        
        tempButton.addTarget(self, action: #selector(self.sendButtonClicked), for: UIControlEvents.touchUpInside)
        return tempButton
    }()
    
    lazy var cancelButton: UIButton = {
        let tempButton = UIButton()

        tempButton.setTitle("取消", for: UIControlState.normal)
        tempButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        tempButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        
        tempButton.addTarget(self, action: #selector(self.cancelButtonClicked), for: UIControlEvents.touchUpInside)
        return tempButton
    }()
    
    // MARK: - events response
    func originalSelectedButtonClicked(button: UIButton) -> Void {
        button.isSelected = !button.isSelected
        print("originalSelectedButtonClicked")
    }
    
    func cancelButtonClicked() -> Void {
        print("cancelButtonClicked")
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendButtonClicked() -> Void {
        
        let thumbImage = getThumbImage()
        
        if originalSelectedButton.isSelected {
            //发原图
            if (sendImageHandler != nil) {
                sendImageHandler!(sourceImage!, thumbImage, true)
            }
            dismiss(animated: true, completion: nil)
            return
        }
        if (sendImageHandler != nil) {
            sendImageHandler!(thumbImage, thumbImage, false)
        }
        dismiss(animated: true, completion: nil)
    }

}
