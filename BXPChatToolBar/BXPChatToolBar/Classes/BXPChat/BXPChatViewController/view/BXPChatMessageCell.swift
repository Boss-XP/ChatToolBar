//
//  BXPChatMessageCell.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/5.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

class BXPChatMessageCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    let averterList = ["demo_avatar_jobs","demo_avatar_cook","demo_avatar_woz"]
    
    var messageWidth: CGFloat = 66
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0)
        selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(leftAvatarImageView)
        leftAvatarImageView.image = UIImage(named: averterList[Int(arc4random_uniform(2))])
        
        contentView.addSubview(rightAvatarImageView)
        rightAvatarImageView.image = UIImage(named: averterList[Int(arc4random_uniform(2))])
        
        contentView.addSubview(leftMessageBackView)
        contentView.addSubview(rightMessageBackView)
        
        leftMessageBackView.addSubview(leftMessageTextLabel)
        rightMessageBackView.addSubview(rightMessageTextLabel)
        
        setupLeft()
        setupRight()
    }
    
    func setupLeft() -> Void {
        /*let constraintLeft = NSLayoutConstraint(item: leftMessageBackView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 66)

        let constraintTop = NSLayoutConstraint(item: leftMessageBackView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
        let constraintBottom = NSLayoutConstraint(item: leftMessageBackView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
        
        let constraintWidth = NSLayoutConstraint(item: leftMessageBackView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 72)
        let constraintHeight = NSLayoutConstraint(item: leftMessageBackView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 50)
        
        contentView.addConstraints([constraintLeft, constraintTop, constraintBottom])
        leftMessageBackView.addConstraints([constraintWidth, constraintHeight])
        */
        let constraintLeft1 = NSLayoutConstraint(item: leftMessageTextLabel, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: leftMessageBackView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 10)
        let constraintRight1 = NSLayoutConstraint(item: leftMessageTextLabel, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: leftMessageBackView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -10)
        
        let constraintTop1 = NSLayoutConstraint(item: leftMessageTextLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: leftMessageBackView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 10)
        let constraintBottom1 = NSLayoutConstraint(item: leftMessageTextLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: leftMessageBackView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -10)
        

        leftMessageBackView.addConstraints([constraintLeft1, constraintTop1, constraintBottom1, constraintRight1])
    }
    
    func setupRight() -> Void {
        /*let constraintRight = NSLayoutConstraint(item: rightMessageBackView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -66)

        let constraintTop = NSLayoutConstraint(item: rightMessageBackView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
        let constraintBottom = NSLayoutConstraint(item: rightMessageBackView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
        
        let constraintWidth = NSLayoutConstraint(item: rightMessageBackView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: messageWidth)
        
        contentView.addConstraints([constraintRight, constraintTop, constraintBottom])
        rightMessageBackView.addConstraints([constraintWidth])
        */
        let constraintLeft1 = NSLayoutConstraint(item: rightMessageTextLabel, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: rightMessageBackView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 10)
        let constraintRight1 = NSLayoutConstraint(item: rightMessageTextLabel, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: rightMessageBackView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -10)
        
        let constraintTop1 = NSLayoutConstraint(item: rightMessageTextLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: rightMessageBackView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 10)
        let constraintBottom1 = NSLayoutConstraint(item: rightMessageTextLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: rightMessageBackView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -10)
        
        
        rightMessageBackView.addConstraints([constraintLeft1, constraintTop1, constraintBottom1, constraintRight1])
    }
    
    lazy var leftAvatarImageView: UIImageView = {
        let tempImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        tempImageView.layer.cornerRadius = 6
        tempImageView.layer.masksToBounds = true
        return tempImageView
    }()
    
    lazy var leftMessageBackView: UIImageView = {
        let tempImageView = UIImageView()//(frame: CGRect(x: 66, y: 10, width: 50, height: 50))
        tempImageView.image = UIImage(named: "chat_bubble_common_left")
//        tempImageView.layer.cornerRadius = 6
//        tempImageView.layer.masksToBounds = true
        return tempImageView
    }()
    
    
    lazy var rightAvatarImageView: UIImageView = {
        let tempImageView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.size.width - 60, y: 10, width: 50, height: 50))
        tempImageView.layer.cornerRadius = 6
        tempImageView.layer.masksToBounds = true
        return tempImageView
    }()
    
    
    lazy var rightMessageBackView: UIImageView = {
        let tempImageView = UIImageView()//(frame: CGRect(x: 66, y: 10, width: 50, height: 50))
        tempImageView.image = UIImage(named: "chat_bubble_common_right")
        return tempImageView
    }()
    
    lazy var leftMessageTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textColor = UIColor.black
//        self.contentView.addSubview(textLabel)
        return textLabel
    }()
    
    lazy var rightMessageTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textColor = UIColor.black
        textLabel.textAlignment = NSTextAlignment.right
//        self.contentView.addSubview(textLabel)
        return textLabel
    }()
    
    func setLeftMessageText(attributeString: NSAttributedString, width: CGFloat) -> Void {
        rightAvatarImageView.isHidden = true
        rightMessageBackView.isHidden = true
        
        var frame = CGRect(x: 62, y: 10, width: 240, height: 80)
        
        leftMessageBackView.frame = frame//CGRect(x: 62, y: 10, width: 240, height: 80)
        frame.origin.x = 15
        frame.origin.y = 10
        frame.size.width -= 25
        frame.size.height -= 20
        leftMessageTextLabel.frame = frame
        
        leftMessageTextLabel.attributedText = attributeString
        if width > 66 {
            messageWidth = width
        }
//        layoutIfNeeded()
//        layoutSubviews()
    }
    
    func setRightMessageText(attributeString: NSAttributedString, width: CGFloat) -> Void {
        leftAvatarImageView.isHidden = true
        leftMessageBackView.isHidden = true
        
        let width: CGFloat = 200
        
        var frame = CGRect(x: UIScreen.main.bounds.size.width - width - 62, y: 10, width: width, height: 80)
        
        rightMessageBackView.frame = frame//CGRect(x: UIScreen.main.bounds.size.width - 240 - 62, y: 10, width: 240, height: 80)
        
        frame.origin.x = 10
        frame.origin.y = 10
        frame.size.width -= 25
        frame.size.height -= 20
        rightMessageTextLabel.frame = frame
        
        rightMessageTextLabel.attributedText = attributeString
        if width > 66 {
            messageWidth = width
        }
//        layoutIfNeeded()
    }
}
