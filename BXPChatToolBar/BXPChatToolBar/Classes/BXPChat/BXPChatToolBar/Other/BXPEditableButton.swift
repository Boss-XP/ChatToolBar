//
//  BXPEditableButton.swift
//  BXPChatToolBar
//
//  Created by Boos－XP on 17/2/25.
//  Copyright © 2017年 Boos－XP. All rights reserved.
//

import UIKit

class BXPEditableButton: UIButton {

    var buttonInputView: UIView? {
        willSet(newButtonInputView) {
            self.textView.inputView = newButtonInputView
        }
        didSet {
        }
    }

    let viewx = UIView()

    override var canBecomeFocused: Bool {
        return true
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var canResignFirstResponder: Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    lazy var textView: UITextView = {
        let tempTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tempTextView.isHidden = true
        self.addSubview(tempTextView)
        return tempTextView
    }()
    
}
