//
//  BXPChatMessageModel.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/2/21.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

enum BXPChatMessageModelType {
    case text
    case picture
    case voice
    case shortVideo
}

class BXPChatMessageModel: NSObject {
    var type: BXPChatMessageModelType?
    var text: NSAttributedString?
    var isMine = true
    
}
