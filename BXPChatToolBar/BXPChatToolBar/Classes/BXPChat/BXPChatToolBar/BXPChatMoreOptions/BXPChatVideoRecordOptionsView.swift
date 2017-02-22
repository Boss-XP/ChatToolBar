//
//  BXPChatVideoRecordOptionsView.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/2/6.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

@objc protocol BXPChatVideoRecordOptionsViewDelegate : NSObjectProtocol{

//    @objc optional func endEditingWithChatMoreOptionViewCellClicked() -> Void;
    @objc optional func changeFlashLightStatus(isOn: Bool)//flashButtonDidClicked()
    @objc optional func cancelButtonDidClicked()
    
    @objc optional func recordButtonTouchDown()
    @objc optional func recordButtonDragExit()
    @objc optional func recordButtonDragEnter()
    @objc optional func recordButtonTouchUpOutside()
    @objc optional func recordButtonTouchUpInside()
    
    @objc optional func finishedRecordWithOverTime()
}

class BXPChatVideoRecordOptionsView: UIView {

    var delegate : BXPChatVideoRecordOptionsViewDelegate?
    
    private var isTouchUp = false
    private var isOverTime = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() -> Void {
        backgroundColor = UIColor.darkGray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(recordButton)
        addSubview(flashButton)
        addSubview(cancelButton)
    }
    
    
    private lazy var recordButton: UIButton = {
        let buttonWH: CGFloat = 66;
        var buttonFrame: CGRect = CGRect.zero
        buttonFrame.size.height = buttonWH
        buttonFrame.size.width = buttonWH
        buttonFrame.origin.x = (self.bounds.size.width - buttonWH) * 0.5
        buttonFrame.origin.y = (self.bounds.size.height - buttonWH) * 0.5

        let tempBUtton = UIButton(frame: buttonFrame)
        
        tempBUtton.setImage(UIImage(named: "record_normal"), for: UIControlState.normal)
        
        tempBUtton.addTarget(self, action: #selector(self.recordButtonTouchDown(_:)), for: UIControlEvents.touchDown)
        tempBUtton.addTarget(self, action: #selector(self.recordButtonDragExit), for: UIControlEvents.touchDragExit)
        tempBUtton.addTarget(self, action: #selector(self.recordButtonDragEnter), for: UIControlEvents.touchDragEnter)
        tempBUtton.addTarget(self, action: #selector(self.recordButtonTouchUpInside), for: UIControlEvents.touchUpInside)
        tempBUtton.addTarget(self, action: #selector(self.recordButtonTouchUpOutside), for: UIControlEvents.touchUpOutside)
        return tempBUtton
    }()
    
    private lazy var cancelButton: UIButton = {
        let buttonW: CGFloat = 46;
        let buttonH: CGFloat = 30;
        var buttonFrame: CGRect = CGRect.zero
        buttonFrame.size.height = buttonH
        buttonFrame.size.width = buttonW
        buttonFrame.origin.x = self.bounds.size.width - buttonW - 15
        buttonFrame.origin.y = (self.bounds.size.height - buttonH) * 0.5
        
        let tempButton = UIButton(frame: buttonFrame)
        
        tempButton.setTitle("取消", for: UIControlState.normal)
        
        tempButton.setTitleColor(UIColor(white: 1.0, alpha: 0.6), for: UIControlState.normal)
        tempButton.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: UIControlState.highlighted)
        
        tempButton.addTarget(self, action: #selector(self.cancelButtonClicked), for: UIControlEvents.touchUpInside)
        return tempButton
    }()

    private lazy var flashButton: UIButton = {
        let buttonH: CGFloat = 30
        let buttonY = (self.bounds.size.height - buttonH) * 0.5
        var buttonFrame: CGRect = CGRect(x: 2, y: buttonY, width: 90, height: buttonH)
        
        let tempButton = UIButton(frame: buttonFrame)
        
        tempButton.setImage(UIImage(named: "flash"), for: UIControlState.normal)
        
        tempButton.setTitle("未开启", for: UIControlState.normal)
        tempButton.setTitle("已开启", for: UIControlState.selected)
        
        tempButton.setTitleColor(UIColor(red: 140/255, green: 140/255, blue: 156/255, alpha: 0.6), for: UIControlState.normal)
        tempButton.setTitleColor(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.6), for: UIControlState.selected)
        
        tempButton.addTarget(self, action: #selector(self.flashLightButtonClicked), for: UIControlEvents.touchUpInside)
        return tempButton
    }()
    
    lazy var timeLineView: UIView = {
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 5))
        tempView.backgroundColor = UIColor.blue
        tempView.isHidden = true
        self.addSubview(tempView)
        return tempView
    }()
    
    
    func startAnimation() -> Void {
        
        isTouchUp = false
        isOverTime = false
        cancelButton.isHidden = true
        flashButton.isHidden = true
        timeLineView.isHidden = false
        
        UIView.animate(withDuration: 0.5) {
            self.recordButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2);
        }
//        timeLineView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        timeLineView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 10, animations: {
            self.timeLineView.transform = CGAffineTransform(scaleX: 0.01, y: 1.0)
        }) { (isFinished) in
            if self.isTouchUp {
                return
            }
            self.isOverTime = true
//            self.timeLineView.removeFromSuperview()
            self.timeLineView.isHidden = true

            self.cancelButton.isHidden = false
            self.flashButton.isHidden = false
            self.recordButton.transform = CGAffineTransform.identity
            
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(BXPChatVideoRecordOptionsViewDelegate.finishedRecordWithOverTime)))! {
                self.delegate?.finishedRecordWithOverTime!()
            }
        }
        
    }
    
    // MARK: - Events Response
    @objc private func recordButtonTouchDown(_ button: UIButton) -> Void {
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatVideoRecordOptionsViewDelegate.recordButtonTouchDown)))! {
            delegate?.recordButtonTouchDown!()
        }
        startAnimation()
    }
    
    @objc private func recordButtonDragExit() -> Void {
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatVideoRecordOptionsViewDelegate.recordButtonDragExit)))! {
            delegate?.recordButtonDragExit!()
        }
    }
    
    @objc private func recordButtonDragEnter() -> Void {
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatVideoRecordOptionsViewDelegate.recordButtonDragEnter)))! {
            delegate?.recordButtonDragEnter!()
        }
    }
    
    @objc private func recordButtonTouchUpInside() -> Void {
        if isOverTime {
            return
        }
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatVideoRecordOptionsViewDelegate.recordButtonTouchUpInside)))! {
            delegate?.recordButtonTouchUpInside!()
        }
        isTouchUp = true
        
        timeLineView.isHidden = true
        timeLineView.layer.removeAllAnimations()
        cancelButton.isHidden = false
        flashButton.isHidden = false
        recordButton.layer.removeAllAnimations()
        recordButton.transform = CGAffineTransform.identity
    }
    
    @objc private func recordButtonTouchUpOutside() -> Void {
        if isOverTime {
            return
        }
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatVideoRecordOptionsViewDelegate.recordButtonTouchUpOutside)))! {
            delegate?.recordButtonTouchUpOutside!()
        }
        isTouchUp = true
        
        timeLineView.isHidden = true
        timeLineView.layer.removeAllAnimations()
        cancelButton.isHidden = false
        flashButton.isHidden = false
        recordButton.layer.removeAllAnimations()
        recordButton.transform = CGAffineTransform.identity
    }
    
    
    @objc private func flashLightButtonClicked() -> Void {
        flashButton.isSelected = !flashButton.isSelected
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatVideoRecordOptionsViewDelegate.changeFlashLightStatus(isOn:))))! {
            delegate?.changeFlashLightStatus!(isOn: flashButton.isSelected)
        }
    }
    
    @objc private func cancelButtonClicked() -> Void {

        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatVideoRecordOptionsViewDelegate.cancelButtonDidClicked)))! {
            delegate?.cancelButtonDidClicked!()
        }
        
    }

}
