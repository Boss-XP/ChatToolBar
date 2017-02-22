//
//  BXPBXPChatMoreOptionCell.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/23.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

class BXPChatMoreOptionCollectionViewCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(optionButton)
    }
    
    lazy var optionButton: BXPChatMoreOptionButton = {
        let tempButton = BXPChatMoreOptionButton(frame: self.bounds)
        tempButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
        tempButton.titleLabel?.textAlignment = NSTextAlignment.center
        tempButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        tempButton.isUserInteractionEnabled = false
        return tempButton
    }()

    func setupOptionsWith(title: String, imageName: String) -> Void {
        optionButton.setTitle(title, for: UIControlState.normal)
        optionButton.setImage(UIImage(named: imageName), for: UIControlState.normal)
    }
}
