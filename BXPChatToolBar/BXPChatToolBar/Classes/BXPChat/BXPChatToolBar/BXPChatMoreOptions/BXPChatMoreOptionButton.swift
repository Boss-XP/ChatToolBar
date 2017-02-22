//
//  BXPChatMoreOptionButton.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/23.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

class BXPChatMoreOptionButton: UIButton {


    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth:CGFloat = self.frame.size.width
        let buttonHeight:CGFloat = self.frame.size.height
        let imageViewWH:CGFloat = 50
        let imageViewX: CGFloat = (buttonWidth - imageViewWH) * 0.5
        let imageViewY: CGFloat = (buttonHeight - imageViewWH) * 0.30;
        
        imageView?.frame = CGRect(x: imageViewX, y: imageViewY, width: imageViewWH, height: imageViewWH)
        
        let labelY: CGFloat = imageViewWH + imageViewY + (buttonHeight - imageViewWH) * 0.1;
        titleLabel?.frame = CGRect(x: 0, y: labelY, width: buttonWidth, height: buttonHeight - labelY)
    }
}
