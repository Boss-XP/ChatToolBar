//
//  BXPChatTextView.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/11.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

class BXPChatTextView: UITextView {
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var originalRect = super.caretRect(for: position)
        originalRect.size.height = (self.font?.lineHeight)! + 1;
        
        originalRect.origin.y += 1.5;
        
        return originalRect;
    }

}
