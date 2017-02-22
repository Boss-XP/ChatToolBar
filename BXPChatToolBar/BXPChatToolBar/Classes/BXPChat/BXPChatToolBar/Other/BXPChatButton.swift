//
//  BXPChatButton.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/11.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

class BXPChatButton: UIButton {

//    override var inputView : UIView!
//    override var inputAccessoryView : UIView?
    var _inputView: UIView?
//    override var inputView: UIView {
//        get {
//            return super.inputView!
//        }
//        set {
////            self.inputView = newValue
////            self.setValue(newValue, forKey: "inputView")
//            _inputView = newValue
//        }
//    }
//    override var inputAccessoryView : UIView {
//        get {
//            return super.inputAccessoryView!
//        }
//        set {
//            
//        }
//    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if _inputView != nil {
            self.setValue(_inputView, forKey: "inputView")
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var canBecomeFocused: Bool {
        return true
    }
    
    override var canResignFirstResponder: Bool {
        return true
    }
    
}
