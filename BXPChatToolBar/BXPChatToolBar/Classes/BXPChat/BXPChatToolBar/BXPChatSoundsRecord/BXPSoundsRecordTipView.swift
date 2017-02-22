//
//  BXPSoundsRecordTipView.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/21.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit


let tipsBackImage = "sound_record"

enum BXPSoundsRecordTipViewState {
    case normalRecording
    case willCancel
    case countingDown
    case countingDownWillCancel
}

class BXPSoundsRecordTipView: UIImageView {


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = CGRect(x: 0, y: 0, width: 170, height: 160)
        self.layer.cornerRadius = 7
        self.layer.masksToBounds = true
        
        self.image = UIImage(named: tipsBackImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addSubview(tipImageView)
        var centerP = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)//self.center
        centerP.y = centerP.y - 18
        tipImageView.center = centerP
        
        self.addSubview(tipsLabel)
        
        self.addSubview(countDownLabel)
        countDownLabel.center = tipImageView.center
    }
    
    lazy var tipImageView: UIImageView = {
        let tempImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 61, height: 95))
        tempImageView.image = UIImage(named: "microphone1")
        
        return tempImageView
    }()
    
    lazy var tipsLabel: UILabel = {
        let boundsRect = self.bounds
        let tempLabel = UILabel(frame: CGRect(x: 7, y: boundsRect.size.height - 25 , width: boundsRect.size.width - 14, height: 20))//UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        tempLabel.textAlignment = NSTextAlignment.center
        tempLabel.font = UIFont.systemFont(ofSize: 13)
        tempLabel.textColor = UIColor.white
        tempLabel.layer.cornerRadius = 5
        tempLabel.layer.masksToBounds = true
        
        return tempLabel
    }()
    
    lazy var countDownLabel: UILabel = {
        let boundsRect = self.bounds
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        tempLabel.textAlignment = NSTextAlignment.center
        tempLabel.font = UIFont.boldSystemFont(ofSize: 52)
        tempLabel.textColor = UIColor.white
        tempLabel.isHidden = true
        return tempLabel
    }()
    
    func showSoundsRecordTipView() -> Void {

        tipImageView.isHidden = false
        countDownLabel.isHidden = true
        tipImageView.image = UIImage(named: "microphone1")
        tipsLabel.text = "手指上划,取消录音"
        tipsLabel.backgroundColor = UIColor.clear
        let topViewController = AppDelegate.shareInstance().topViewController()
        topViewController.view.addSubview(self)
        self.center = topViewController.view.center
        layoutIfNeeded()
    }
    
    func updateSoundsRecordTipViewWithTimeTooShort() -> Void {
//        self.tipLabel.text = @"说话时间太短";
//        UIViewController *topViewController = [AppDelegate shareInstance].topViewController;
//        if (topViewController) {
//            [topViewController.view addSubview:self];
//            self.center = topViewController.view.center;
//        }
//        __block UIImageView *timeTooShortV = timeTooshort;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [timeTooShortV removeFromSuperview];
//            [self removeFromSuperview];
//            });
        let tooshortView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 95))
        tooshortView.image = UIImage(named: "timeTooShort")
        addSubview(tooshortView)
        tooshortView.center = tipImageView.center
        
        tipImageView.isHidden = true
        
        tipsLabel.text = "说话时间太短"
        
        tipsLabel.backgroundColor = UIColor(red: 252/255, green: 78/255, blue: 68/255, alpha: 0.5)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            tooshortView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    func updateTipsImageWithVoiceVolumnLever(voiceVolumnLever: NSInteger) -> Void {
        tipImageView.isHidden = false
        let imageName = NSString(format: "microphone%d", voiceVolumnLever) as String
        tipImageView.image = UIImage(named: imageName)
    }
    
    func updateTipsMessageState(state: BXPSoundsRecordTipViewState) -> Void {
        if state == BXPSoundsRecordTipViewState.normalRecording {
            tipsLabel.text = "手指上划,取消录音"
            tipsLabel.backgroundColor = UIColor.clear
            tipImageView.image = UIImage(named: "microphone1")
            return
        }
        if state == BXPSoundsRecordTipViewState.willCancel {
            tipsLabel.text = "松开手指,取消录音"
            tipsLabel.backgroundColor = UIColor(red: 252/255, green: 78/255, blue: 68/255, alpha: 0.5)
            tipImageView.image = UIImage(named: "touchup_cancel_record")
//            print("---willCancel")
            return
        }
        
        if state == BXPSoundsRecordTipViewState.countingDown {
            tipsLabel.text = "手指上划,取消录音"
            tipsLabel.backgroundColor = UIColor.clear
//            tipImageView.image = UIImage(named: "touchup_cancel_record")
            return
        }
        
        if state == BXPSoundsRecordTipViewState.countingDownWillCancel {
            tipsLabel.text = "松开手指,取消录音"
            tipsLabel.backgroundColor = UIColor(red: 252/255, green: 78/255, blue: 68/255, alpha: 0.5)
//            tipImageView.image = UIImage(named: "touchup_cancel_record")
            return
        }
    }
    
    func updateTipsMessageCountingDown(countNumber: NSInteger) -> Void {
        tipImageView.isHidden = true
        countDownLabel.isHidden = false
        countDownLabel.text = "\(countNumber)"
        
        if countNumber == 0 {
            tipsLabel.text = "时间超过一分钟,自动发送"
            tipsLabel.backgroundColor = UIColor(red: 252/255, green: 78/255, blue: 68/255, alpha: 0.5)
        }
    }
    
    func hidenTipView() -> Void {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            
            self.removeFromSuperview()
        }
    }

}
