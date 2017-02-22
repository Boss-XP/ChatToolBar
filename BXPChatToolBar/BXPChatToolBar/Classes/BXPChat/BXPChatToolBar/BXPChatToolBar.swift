//
//  BXPChatToolBar.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/5.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit
import Foundation
import CoreFoundation


let kToolBarDefaultHeight : CGFloat = 49.0
//let kTextViewDefaultHeight : CGFloat = 34.0
let kTextViewMaxHeight : CGFloat = 113//72.0
let kTextViewSignalLineHeight: CGFloat = 36

let kButtonPadding : CGFloat = 5

let voiceButtonImageNormal = "chat_yuyin"
let voiceButtonImageSelected = "chat_key"

let chatFaceButtonImage = "chat_expression"
let chatMoreButtonImage = "chat_add_nor"


@objc protocol BXPChatToolBarDelegate : NSObjectProtocol {
    
    @objc optional func chatToolBarShouldChangeFrameWithInputEvents(_ chatToolBar: BXPChatToolBar, estimatedFrame: CGRect, currentFrame: CGRect, duration: CGFloat) -> Bool
    
    @objc optional func chatToolBarShouldChangeFrameWithKeyboardEvents(_ chatToolBar: BXPChatToolBar, estimatedFrame: CGRect, currentFrame: CGRect, duration: CGFloat, isRise: Bool) -> Bool
}

@objc protocol BXPChatToolBarDataSource : NSObjectProtocol {

    @objc optional func chatToolBarSendTextMessage(_ chatToolBar :BXPChatToolBar, attributeString: NSAttributedString) -> Void
    @objc optional func chatToolBarSendVoiceMessage(_ chatToolBar :BXPChatToolBar, voicePath: String, duration: TimeInterval) -> Void
    @objc optional func chatToolBarSendImageMessage(_ chatToolBar :BXPChatToolBar, image: UIImage, thumbImage: UIImage, isOriginal: Bool) -> Void
    @objc optional func chatToolBarSendVideoMessage(_ chatToolBar :BXPChatToolBar, videoPath: String, duration: TimeInterval, thumbImage: UIImage) -> Void
}

public class BXPChatToolBar: UIView, UITextViewDelegate, BXPChatFaceViewDelegate, BXPChatSoundsRecorderDeleagte, BXPChatMoreOptionViewDelegate {
    
    enum BXPChatToolBarStyle {
        case defaults
        case textOnly
        case emoji
    }
    
    weak var delegate: BXPChatToolBarDelegate?
    weak var dataSource: BXPChatToolBarDataSource?
    
    private var soundsRecorder : BXPChatSoundsRecorder?

    private var isKeyBordShown = false;
    private var lastKeyBordHeight : CGFloat = 0;
    private var isMonitorKeyboardEvents = true;
    private var originY : CGFloat = 0.0;
    private var _style : BXPChatToolBarStyle?
    
    private var toolBarHeightBeforeSoundsRecord : CGFloat = 49.0;
    private var isObserverTextViewContentSize = true
  
    init(frame: CGRect, style: BXPChatToolBarStyle) {
        super.init(frame: frame)
        
        _style = style
        
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        textView.removeObserver(self, forKeyPath: "contentSize", context: &textViewContext)
    }

    // MARK: - setup UI
    private func setupUI() -> Void {

        var frame = self.frame
        frame.size.height = CGFloat(kToolBarDefaultHeight)
        frame.size.width = UIScreen.main.bounds.size.width
        self.frame = frame
        
        self.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        
//        let padding = 10.0;
//        var leftMargin = 0.0;
//        var rightMargin = 0.0;
//        if _style == BXPChatToolBarStyle.textOnly {
//            leftMargin = 12;
//            rightMargin = 67.5;
//        } else if _style == BXPChatToolBarStyle.emoji {
//            leftMargin = 52;
//            rightMargin = 67.5;
//        } else {
//            leftMargin = 48;
//            rightMargin = 86;
//        }
//        _maxWidth = UIScreen.main.bounds.size.width - CGFloat(leftMargin) - CGFloat(rightMargin) - CGFloat(padding);

        addObservers()
    }
    
    var textViewContext = "textView.contentSize.kvo"
    func addObserversForTextView() -> Void {

        textView.addObserver(self, forKeyPath: "contentSize", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: &textViewContext)
    }
    
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if isObserverTextViewContentSize && keyPath == "contentSize" && context == &textViewContext {
            
            let oldSize = change?[NSKeyValueChangeKey.oldKey] as! CGSize
            let newSize = change?[NSKeyValueChangeKey.newKey] as! CGSize
            
            let currentHeight = newSize.height
            var deltaY = newSize.height - oldSize.height
            
            if currentHeight > kTextViewSignalLineHeight {
                if deltaY < 0 && (self.frame.size.height + deltaY) < kToolBarDefaultHeight {
                    deltaY = kToolBarDefaultHeight - self.frame.size.height
                }
                updataTextViewHeight(dy: deltaY)
                return
            }
            if currentHeight == kTextViewSignalLineHeight && deltaY < 0 {
                if (self.frame.size.height + deltaY) < kToolBarDefaultHeight {
                    deltaY = kToolBarDefaultHeight - self.frame.size.height
                }
                updataTextViewHeight(dy: deltaY)
            }
        }
    }
    
    private var lastIsBig: Bool = false
    func updataTextViewHeight(dy: CGFloat) -> Void {
        
        if abs(Int32(dy)) == 24 {
            return
        }
        var ddyy: CGFloat = dy
        let contentSizeIsIncreasing: Bool = (ddyy > 0)
        
        if self.frame.size.height >= kTextViewMaxHeight {//kTextViewMaxHeight
            let contentOffsetIsPositive: Bool = (textView.contentOffset.y > 0)
            if contentSizeIsIncreasing || contentOffsetIsPositive {
                scrollTextViewToBottomAnimated(animated: true)
                lastIsBig = true
                return
            }
        }
        
        let toolbarOriginY = self.frame.size.height//textView.frame.origin.y
        let newToolbarOriginY = toolbarOriginY + ddyy
        
        if newToolbarOriginY >= kTextViewMaxHeight {
            ddyy = kTextViewMaxHeight - toolbarOriginY//newToolbarOriginY - 113
            lastIsBig = true
            scrollTextViewToBottomAnimated(animated: true)
        } else {
            if lastIsBig && ddyy < 0 {
                ddyy += 9;
            }
            lastIsBig = false
        }
        
        adjustInputToolbarHeightConstraintByDelta(deltaY: ddyy)
        
        if dy < 0 {
            scrollTextViewToBottomAnimated(animated: false)
        }
    }
    
    func scrollTextViewToBottomAnimated(animated: Bool) -> Void {
        
        let contentOffsetToShowLastLine: CGPoint = CGPoint(x: 0, y: textView.contentSize.height - textView.bounds.height)
        textView.contentOffset = contentOffsetToShowLastLine;
        if !animated {
            textView.contentOffset = contentOffsetToShowLastLine;
            return
        }

        UIView.animate(withDuration: 0.01, delay: 0.01, options: UIViewAnimationOptions.curveLinear, animations: {
            self.textView.contentOffset = contentOffsetToShowLastLine;
        }, completion: nil)
    }
    
    func adjustInputToolbarHeightConstraintByDelta(deltaY: CGFloat) -> Void {
        
        if deltaY == 0 {
            return
        }

        var dy = deltaY
        var frame = self.frame
    
        if (self.frame.size.height + deltaY) > kTextViewMaxHeight {
            dy = kTextViewMaxHeight - frame.size.height
        }
        
        frame.origin.y -= dy
        frame.size.height += dy;
        self.frame = frame
        
        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }
    
    // MARK: - layoutSubviews
    private var hasAddTextViewObserver = false
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //addSubViews && makeConstraints
        addSubview(textView)
        makeConstraintsForTextView()
        
        
        if _style != BXPChatToolBarStyle.defaults {
            addSubview(sendButton)
            makeConstraintsForSendButton()
        }
        
        if _style != BXPChatToolBarStyle.textOnly {
            addSubview(chatFaceButton)
            makeConstraintsForChatFaceButton()
        }
        
        if _style == BXPChatToolBarStyle.defaults {
            addSubview(voiceButton)
            makeConstraintsForVoiceButton()
            
            addSubview(chatMoreButton)
            makeConstraintsForChatMoreButton()
            
            addSubview(soundsRecordButton)
            makeConstraintsForSoundsRecordButton()
        }

        if !hasAddTextViewObserver {
            hasAddTextViewObserver = true
            addObserversForTextView()
        }
    }
    
    private func makeConstraintsForTextView() -> Void {
        
        var leftMargin : CGFloat = 0.0
        var rightMargin : CGFloat = 0.0
        
        if _style == BXPChatToolBarStyle.textOnly {
            leftMargin = 12
            rightMargin = -67.5
        } else if _style == BXPChatToolBarStyle.emoji {
            leftMargin = 52
            rightMargin = -67.5
        } else {
            leftMargin = 48;
            rightMargin = -86;
        }
        
        let constraintLeft = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: leftMargin)
        let constraintRight = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: rightMargin)
        
        let constraintTop = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 8)
        let constraintBottom = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -8)
        
        self.addConstraints([constraintTop, constraintLeft, constraintBottom, constraintRight])
    }


    private func makeConstraintsForSendButton() -> Void {
    
        let constraintRight = NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -10)
        let constraintBottom = NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -7.5)
        
        let constraintWidth = NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 48)
        let constraintHeight = NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 34)
        
        self.addConstraints([constraintRight, constraintBottom])
        sendButton.addConstraints([constraintWidth, constraintHeight])
    }
    
    private func makeConstraintsForChatFaceButton() -> Void {

        let constraintLeft = NSLayoutConstraint(item: chatFaceButton, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 7)
        
        let constraintRight = NSLayoutConstraint(item: chatFaceButton, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -40)
        
        let constraintBottom = NSLayoutConstraint(item: chatFaceButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -2.5)
        
        let constraintWidth = NSLayoutConstraint(item: chatFaceButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44)
        let constraintHeight = NSLayoutConstraint(item: chatFaceButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44)
        
        if _style == BXPChatToolBarStyle.emoji {
            self.addConstraints([constraintLeft, constraintBottom])
        } else {
            self.addConstraints([constraintRight, constraintBottom])
        }
        chatFaceButton.addConstraints([constraintWidth,constraintHeight])
    }
    
    private func makeConstraintsForVoiceButton() -> Void {
        
        let constraintLeft = NSLayoutConstraint(item: voiceButton, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 2)
        
        let constraintBottom = NSLayoutConstraint(item: voiceButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -2.5)
        
        let constraintWidth = NSLayoutConstraint(item: voiceButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44)
        let constraintHeight = NSLayoutConstraint(item: voiceButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44)
        
        self.addConstraints([constraintLeft, constraintBottom])
        voiceButton.addConstraints([constraintWidth,constraintHeight])
    }
    
    private func makeConstraintsForChatMoreButton() -> Void {
        
        let constraintRight = NSLayoutConstraint(item: chatMoreButton, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -5)
        
        let constraintBottom = NSLayoutConstraint(item: chatMoreButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -2.5)
        
        let constraintWidth = NSLayoutConstraint(item: chatMoreButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44)
        let constraintHeight = NSLayoutConstraint(item: chatMoreButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44)
        
        self.addConstraints([constraintRight, constraintBottom])
        chatMoreButton.addConstraints([constraintWidth,constraintHeight])
    }
    
    private func makeConstraintsForSoundsRecordButton() -> Void {

        let constraintLeft = NSLayoutConstraint(item: soundsRecordButton, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 48)
        let constraintRight = NSLayoutConstraint(item: soundsRecordButton, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -86)

        let constraintTop = NSLayoutConstraint(item: soundsRecordButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 8)
        let constraintBottom = NSLayoutConstraint(item: soundsRecordButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -8)

        self.addConstraints([constraintTop, constraintLeft, constraintBottom, constraintRight])
    }

    // MARK: - addObservers
    private func addObservers() -> Void {

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHiden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - keyboard Events
    @objc private func keyboardWillShow(notification: NSNotification) {
    
        if !isMonitorKeyboardEvents {
            return
        }

        if originY == 0 {
            originY = self.frame.origin.y;
        }
        
        let kbInfo = notification.userInfo
        
        let keyBoardFrame = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        let keyboardHeight = keyBoardFrame.size.height
        
        if isKeyBordShown {
            if keyboardHeight == lastKeyBordHeight {
                return;
            }
        }
        
        if keyboardHeight > 0 {
        
            let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
            
            var changePointY = true
            var rect = self.frame
            rect.origin.y = originY - keyboardHeight - rect.size.height + kToolBarDefaultHeight
            var isUpward = true
            if lastKeyBordHeight > keyboardHeight {
                isUpward = false;
            }

            if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatToolBarDelegate.chatToolBarShouldChangeFrameWithKeyboardEvents(_:estimatedFrame:currentFrame:duration:isRise:))))! {
                changePointY = (delegate?.chatToolBarShouldChangeFrameWithKeyboardEvents!(self, estimatedFrame: rect, currentFrame: self.frame, duration: duration ,isRise: isUpward))!
            }
            
            isKeyBordShown = true
            if !changePointY {
                lastKeyBordHeight = keyBoardFrame.size.height;
                return;
            }
            
            self.frame = rect
            
            lastKeyBordHeight = keyboardHeight
        }
    }
    @objc private func keyboardWillHiden(notification: NSNotification) {

        let kbInfo = notification.userInfo
        let keyBoardFrame = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        if !isMonitorKeyboardEvents {
            return;
        }
        
        if !isKeyBordShown {
            return;
        }

        if (keyBoardFrame.size.height > 0) {
            
            isKeyBordShown = false;
            let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat

            var isChangePointY = true
            
            var rect = self.frame
            rect.origin.y += keyBoardFrame.size.height;
            
            if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatToolBarDelegate.chatToolBarShouldChangeFrameWithKeyboardEvents(_:estimatedFrame:currentFrame:duration:isRise:))))! {
                isChangePointY = (delegate?.chatToolBarShouldChangeFrameWithKeyboardEvents!(self, estimatedFrame: rect, currentFrame: self.frame, duration: duration, isRise: false))!
            }
            
            lastKeyBordHeight = 0;
            if !isChangePointY {
                return;
            }
            
            self.frame = rect;
//            UIView.animate(withDuration: TimeInterval(duration), animations: {
//                
//            })
        }
    }

    // MARK: - Getter
    lazy private var textView: BXPChatTextView = {
        var tempView = BXPChatTextView()
        tempView.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 0.9)
        tempView.delegate = self
        tempView.layer.borderWidth = 0.5
        tempView.layer.borderColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0).cgColor
        tempView.layer.cornerRadius = 6
        tempView.layer.masksToBounds = true
        tempView.font = UIFont.systemFont(ofSize: 16)
        tempView.returnKeyType = UIReturnKeyType.send
        tempView.translatesAutoresizingMaskIntoConstraints = false
        tempView.autoresizesSubviews = true
        return tempView
    }()
    
    lazy private var sendButton: UIButton = {
        var tempButton = UIButton()
        tempButton.layer.cornerRadius = 5
        tempButton.layer.masksToBounds = true
        tempButton.backgroundColor = UIColor(red: 0.0, green: 198/255.0, blue: 129/255.0, alpha: 1.0)
        tempButton.setTitle("发送", for: UIControlState.normal)
        tempButton.translatesAutoresizingMaskIntoConstraints = false
        tempButton.addTarget(self, action: #selector(BXPChatToolBar.sendButtonClicked), for: UIControlEvents.touchUpInside)
        return tempButton
    }()

    lazy private var chatFaceButton: BXPEditButton = {
        var tempButton = BXPEditButton()
        tempButton.setImage(UIImage(named:chatFaceButtonImage), for: UIControlState.normal)
        tempButton.setImage(UIImage(named:chatFaceButtonImage), for: UIControlState.highlighted)
        tempButton.imageEdgeInsets = UIEdgeInsetsMake(kButtonPadding, kButtonPadding, kButtonPadding, kButtonPadding)
        tempButton.addTarget(self, action: #selector(BXPChatToolBar.chatFaceButtonClicked), for: UIControlEvents.touchUpInside)
        tempButton.translatesAutoresizingMaskIntoConstraints = false
        
        let inputView = BXPChatFaceView(frame: CGRect(x: 0, y: 0, width: 375, height: 100))
        inputView.delegate = self
        tempButton.inputView = inputView
        
        return tempButton
    }()
    
    lazy private var chatMoreButton: BXPEditButton = {
        var tempButton = BXPEditButton()
        tempButton.setImage(UIImage(named:chatMoreButtonImage), for: UIControlState.normal)
        tempButton.setImage(UIImage(named:chatMoreButtonImage), for: UIControlState.highlighted)
        tempButton.imageEdgeInsets = UIEdgeInsetsMake(kButtonPadding, kButtonPadding, kButtonPadding, kButtonPadding)
        tempButton.addTarget(self, action: #selector(BXPChatToolBar.chatMoreButtonClicked), for: UIControlEvents.touchUpInside)
        tempButton.translatesAutoresizingMaskIntoConstraints = false
        
        let inputView = BXPChatMoreOptionView(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        inputView.delegate = self

        tempButton.inputView = inputView
        
        return tempButton
    }()
    
    lazy private var voiceButton: UIButton = {
        var tempButton = UIButton()
        
        tempButton.setImage(UIImage(named:voiceButtonImageNormal), for: UIControlState.normal)
        tempButton.setImage(UIImage(named:voiceButtonImageSelected), for: UIControlState.selected)
        tempButton.imageEdgeInsets = UIEdgeInsetsMake(kButtonPadding, kButtonPadding, kButtonPadding, kButtonPadding)
        
        tempButton.translatesAutoresizingMaskIntoConstraints = false

        tempButton.addTarget(self, action: #selector(BXPChatToolBar.chatVoiceButtonClicked(_:)), for: UIControlEvents.touchUpInside)
        return tempButton
    }()
    

    lazy var soundsRecordButton: UIButton = {
        let tempButton = UIButton()
        tempButton.layer.borderColor = UIColor.init(white: 0.8, alpha: 1.0).cgColor
        tempButton.layer.borderWidth = 0.6
        tempButton.layer.cornerRadius = 6
        tempButton.backgroundColor = UIColor.white
        
        tempButton.setTitleColor(UIColor(red: 27/255, green: 27/255, blue: 34/255, alpha: 1.0), for: UIControlState.normal)
        tempButton.setTitle("按下 说话", for: UIControlState.normal)
        tempButton.setTitle("松开 发送", for: UIControlState.highlighted)
        tempButton.translatesAutoresizingMaskIntoConstraints = false
        tempButton.isHidden = true
        
        tempButton.addTarget(self, action: #selector(self.soundsRecordButtonTouchDown), for: UIControlEvents.touchDown)
        tempButton.addTarget(self, action: #selector(self.soundsRecordButtonDragExit), for: UIControlEvents.touchDragExit)
        tempButton.addTarget(self, action: #selector(self.soundsRecordButtonDragEnter), for: UIControlEvents.touchDragEnter)
        tempButton.addTarget(self, action: #selector(self.soundsRecordButtonTouchUpInside), for: UIControlEvents.touchUpInside)
        tempButton.addTarget(self, action: #selector(self.soundsRecordButtonTouchUpOutside), for: UIControlEvents.touchUpOutside)
        
        return tempButton
    }()


    // MARK: - utility
    func sendTextMessage() -> Void {
        
        let sendText = textView.text.replacingOccurrences(of: "\n", with: "")
        if sendText.characters.count > 0 {
            
            if (dataSource != nil) && (dataSource?.responds(to: #selector(BXPChatToolBarDataSource.chatToolBarSendTextMessage(_:attributeString:))))! {

                dataSource?.chatToolBarSendTextMessage!(self, attributeString: textView.attributedText)
            }
        }
        
        textView.text = "";
    }

    // MARK: - Events Response
    @objc private func sendButtonClicked() -> Void {
        
        sendTextMessage()
    }
    
    @objc private func chatFaceButtonClicked() -> Void {
        
        if voiceButton.isSelected {
            
            isObserverTextViewContentSize = true
            soundsRecordButton.isHidden = true
            if toolBarHeightBeforeSoundsRecord != kToolBarDefaultHeight {
                var frame = self.frame
                frame.origin.y -= toolBarHeightBeforeSoundsRecord - kToolBarDefaultHeight
                frame.size.height = toolBarHeightBeforeSoundsRecord
                self.frame = frame
            }
            textView.isHidden = false
            voiceButton.isSelected = false
        }
        
        chatFaceButton.becomeFirstResponder()
    }
    
    @objc private func chatMoreButtonClicked() -> Void {
        
//        if voiceButton.isSelected {
//            
//            isObserverTextViewContentSize = true
//            soundsRecordButton.isHidden = true
//            if toolBarHeightBeforeSoundsRecord != kToolBarDefaultHeight {
//                var frame = self.frame
//                frame.origin.y -= toolBarHeightBeforeSoundsRecord - kToolBarDefaultHeight
//                frame.size.height = toolBarHeightBeforeSoundsRecord
//                self.frame = frame
//            }
//            textView.isHidden = false
//            voiceButton.isSelected = false
//        }
        
        chatMoreButton.becomeFirstResponder()
    }
    
    @objc private func chatVoiceButtonClicked(_ button: UIButton) -> Void {
        button.isSelected = !button.isSelected
        
        if button.isSelected {
            
            soundsRecordButton.isHidden = false
            toolBarHeightBeforeSoundsRecord = self.bounds.size.height
            textView.isHidden = true
            if toolBarHeightBeforeSoundsRecord != kToolBarDefaultHeight {
                isObserverTextViewContentSize = false
                var frame = self.frame
                frame.origin.y += toolBarHeightBeforeSoundsRecord - kToolBarDefaultHeight
                frame.size.height = kToolBarDefaultHeight
                self.frame = frame
                layoutIfNeeded()
                layoutSubviews()
            }

            self.textView.resignFirstResponder()
            chatFaceButton.resignFirstResponder()
            chatMoreButton.resignFirstResponder()
            return
        }
        
        isObserverTextViewContentSize = true
        soundsRecordButton.isHidden = true
        if toolBarHeightBeforeSoundsRecord != kToolBarDefaultHeight {
            var frame = self.frame
            frame.origin.y -= toolBarHeightBeforeSoundsRecord - kToolBarDefaultHeight
            frame.size.height = toolBarHeightBeforeSoundsRecord
            self.frame = frame
//            toolBarHeightBeforeSoundsRecord = frame.size.height//self.bounds.size.height
        }
        textView.isHidden = false
    }
    
    @objc private func soundsRecordButtonTouchDown() -> Void {
        
        soundsRecorder = BXPChatSoundsRecorder()
        soundsRecorder?.delegate = self
        soundsRecorder?.startRecord()
    }
    
    @objc private func soundsRecordButtonDragExit() -> Void {
        
        soundsRecorder?.willCancelRecording()
    }
    
    @objc private func soundsRecordButtonDragEnter() -> Void {
        
        soundsRecorder?.continueRecording()
    }
    
    @objc private func soundsRecordButtonTouchUpInside() -> Void {
        
        soundsRecorder?.stopRecording()
    }
    
    @objc private func soundsRecordButtonTouchUpOutside() -> Void {
        
        soundsRecorder?.cancelRecording()
    }
    
    // MARK: - UITextViewDelegate
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if text == "\n" && textView.text.characters.count > 0 {
            
            sendTextMessage()
            return false;
        }
        return true
    }
    
    // MARK: - BXPChatFaceViewDelegate
    private let sizeWH: CGFloat = 20
    func chatFaceView(_ chatFaceView: BXPChatFaceView, didSelected item: BXPFaceItemModel) {
        
        let attachment = NSTextAttachment()
        attachment.image = item.faceImage
        attachment.bounds = CGRect(x: 0, y: -6, width: sizeWH, height: sizeWH)
        let emojiAttributedString = NSAttributedString(attachment: attachment)
        let textViewAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        var range = textView.selectedRange
        
        textViewAttributedString.replaceCharacters(in: range, with: emojiAttributedString)
        
        range.length = 1
        textViewAttributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: range)
        textView.attributedText = textViewAttributedString
        range.location += 1
        range.length = 0
        textView.selectedRange = range
        
        if (textView.bounds.size.height + sizeWH) > kTextViewMaxHeight {
            scrollTextViewToBottomAnimated(animated: true)
        }
        
    }
    
    func chatFaceViewDidClikcedDeleteItem(_ chatFaceView: BXPChatFaceView) {

        if textView.text.characters.count == 0 {
            return
        }
        
        let range = NSMakeRange(textView.text.characters.count - 1, 1)
        let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        mutableAttributedString.deleteCharacters(in: range)
        textView.attributedText = mutableAttributedString
        
        if (textView.bounds.size.height + sizeWH) > kTextViewMaxHeight {
            scrollTextViewToBottomAnimated(animated: true)
        }
    }
    
    func chatFaceViewDidSendButton(_ chatFaceView: BXPChatFaceView) {
        sendTextMessage()
    }
    
    // MARK: - BXPChatSoundsRecorderDeleagte
    func chatSoundsRecorderChatSoundsRecorderOnPermission() {
        
        print("haoNoPermission for sounds record")
    }
    
    func chatSoundsRecorderPathForSoundsSave() -> String {
        return "jdflkjjfls.fjf"
    }
    
    func chatSoundsRecorderDidFinishedRecordSounds(soundsPath: String, duration: TimeInterval) {
        if (dataSource != nil) && (dataSource?.responds(to: #selector(BXPChatToolBarDataSource.chatToolBarSendVoiceMessage(_:voicePath:duration:))))! {
            dataSource?.chatToolBarSendVoiceMessage!(self, voicePath: soundsPath, duration: duration)
        }
    }
    
    
    
    // MARK: - BXPChatMoreOptionViewDelegate
    
    func chatMoreOptionViewEndEditingWithChatMoreOptionViewCellClicked() {
        
        chatMoreButton.resignFirstResponder()
    }
    
    func chatMoreOptionViewDidFinishedGetImage(image: UIImage, thumbImage: UIImage, isOriginal: Bool) {
        if (dataSource != nil) && (dataSource?.responds(to: #selector(BXPChatToolBarDataSource.chatToolBarSendImageMessage(_:image:thumbImage:isOriginal:))))! {
            dataSource?.chatToolBarSendImageMessage!(self, image: image, thumbImage: thumbImage, isOriginal: isOriginal)
        }
    }
    

    func chatMoreOptionViewDidFinishedRecordVideo(videoPath: String, thumbImage: UIImage, duration: TimeInterval) {

        if (dataSource != nil) && (dataSource?.responds(to: #selector(BXPChatToolBarDataSource.chatToolBarSendVideoMessage(_:videoPath:duration:thumbImage:))))! {
            dataSource?.chatToolBarSendVideoMessage!(self, videoPath: videoPath, duration: duration, thumbImage: thumbImage)
        }
    }
    
}









