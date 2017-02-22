//
//  BXPChatSoundsRecorder.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/20.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit
import AVFoundation


@objc protocol BXPChatSoundsRecorderDeleagte: NSObjectProtocol {
    @objc optional func chatSoundsRecorderChatSoundsRecorderOnPermission()
    @objc optional func chatSoundsRecorderPathForSoundsSave() -> String;
    @objc optional func chatSoundsRecorderDidFinishedRecordSounds(soundsPath: String, duration: TimeInterval)
}

enum BXPChatSoundsRecorderState {
    case ready
    case recording
    case willCancel
    case recordingOnCountingDown
    case willCancelOnCountingDown
    
    case finished
    case canceled
    
    case overTime
    case timeTooShort
}

class BXPChatSoundsRecorder: NSObject {

    weak var delegate: BXPChatSoundsRecorderDeleagte?
    
    private var recorder: AVAudioRecorder!
    private var volumeLeverCheckTimer: Timer!
    private var soundsRecordTimeCountTimer: Timer!

    private var beginDate: Date?
    private var soundsSavePath = ""
    
    private var state: BXPChatSoundsRecorderState!
    
    static var sharedInstance: BXPChatSoundsRecorder {
        struct Static {
            static let instance: BXPChatSoundsRecorder = BXPChatSoundsRecorder()
        }
        return Static.instance
    }

    private func initMicrophone() -> Void {

        //获取权限
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:))) {
            audioSession.requestRecordPermission({ (isAvailable) in
                if !isAvailable {
                    //无权限
                    if (self.delegate != nil) && (self.delegate?.responds(to: #selector(BXPChatSoundsRecorderDeleagte.chatSoundsRecorderChatSoundsRecorderOnPermission)))! {
                        self.delegate?.chatSoundsRecorderChatSoundsRecorderOnPermission!()
                    }
                    self.showNoPermission(title: "无法录音")
                    return
                }
                
                if self.state != BXPChatSoundsRecorderState.ready {
                    return
                }
                
                self.setupRecorder()
                if self.recorder != nil {
                    self.recorder?.isMeteringEnabled = true
                    self.recorder?.prepareToRecord()
                    self.soundsRecording()

                    return
                }
                
                self.showNoPermission(title: "录音失败")
                
                if (self.delegate != nil) && (self.delegate?.responds(to: #selector(BXPChatSoundsRecorderDeleagte.chatSoundsRecorderChatSoundsRecorderOnPermission)))! {
                    self.delegate?.chatSoundsRecorderChatSoundsRecorderOnPermission!()
                }
            })
        }
    }
    
    func showNoPermission(title: String) -> Void {
    
        let alertController = UIAlertController(title: title, message: "请在“设置-隐私-麦克风”中允许访问麦克风。", preferredStyle: .alert)
        
        //                    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default, handler:{
            (UIAlertAction) -> Void in
            
        })
        //                    alertView.addAction(cancelAction)
        alertController.addAction(okAction)
        let topVC = AppDelegate.shareInstance().topViewController()
        topVC.present(alertController, animated: true, completion: nil)
    }
    
    private func setupRecorder() -> Void {
        
//        let session:AVAudioSession = AVAudioSession.sharedInstance()
//        //设置录音类型
//        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
//        //设置支持后台
//        try! session.setActive(true)
        
        //录音设置
        let recordSetting = [
//
            AVFormatIDKey: NSNumber(value: Int32(kAudioFormatMPEG4AAC)),//(value: kAudioFormatMPEG4AAC),//录音格式
            AVNumberOfChannelsKey: 1, //录音的声道数，立体声为双声道
            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue,//录音质量
//            AVEncoderBitRateKey : 320000,
            AVSampleRateKey : 44100.0, //录音器每秒采集的录音样本数 采样率(Hz)
            AVLinearPCMBitDepthKey : NSNumber(value: 16) //线性采样位数  8、16、24、32
        ] as [String : Any]

        //设置录音文件保存地址
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatSoundsRecorderDeleagte.chatSoundsRecorderPathForSoundsSave)))! {
            soundsSavePath = (delegate?.chatSoundsRecorderPathForSoundsSave!())!
        }

        let docDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]

        if soundsSavePath.characters.count == 0 || !soundsSavePath.hasSuffix(".mp4") {

            let dataStr = Date().timeIntervalSinceReferenceDate

            soundsSavePath = docDir + "/chatToolBatSounds-\(dataStr)-play.mp4"
        }
        
        let saveUrl = URL(fileURLWithPath: soundsSavePath)

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
//            try audioRecorder = AVAudioRecorder(URL: self.directoryURL()!,
//                                                settings: recordSettings)//初始化实例
//            audioRecorder.prepareToRecord()//准备录音
            recorder = try! AVAudioRecorder(url: saveUrl, settings: recordSetting)
        } catch {
        }
    }
    
    // MARK: - Getter
    lazy var tipView: BXPSoundsRecordTipView = {
        let tempView = BXPSoundsRecordTipView(frame: CGRect.zero)
        return tempView
    }()
    
    private func soundsRecording() -> Void {
        soundsRecordTimeCountNumber = 0

        if !recorder.isRecording {//判断是否正在录音状态
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                
                recorder.record()
                self.state = BXPChatSoundsRecorderState.recording
                
                beginDate = Date()

                if volumeLeverCheckTimer != nil {
                    volumeLeverCheckTimer.invalidate()
                    volumeLeverCheckTimer = nil
                }
                volumeLeverCheckTimer = Timer(fireAt: Date(timeIntervalSinceNow: 0.5), interval: 0.2, target: self, selector: #selector(self.volumeLevelChangeCheck), userInfo: nil, repeats: true)
                RunLoop.current.add(volumeLeverCheckTimer, forMode: RunLoopMode.commonModes)

                soundsRecordTimeCountTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.soundsRecordTimeCount), userInfo: nil, repeats: true)
                RunLoop.current.add(soundsRecordTimeCountTimer, forMode: RunLoopMode.commonModes)
                
                tipView.showSoundsRecordTipView()
            } catch {
            }
            return
        }
        recorder.stop()
    }
    
    var volumeLevel: NSInteger = 0
    
    @objc private func volumeLevelChangeCheck() -> Void {
        
        recorder!.updateMeters() // 刷新音量数据
//        let averageV: Float = (recorder?.averagePower(forChannel: 0))! //获取音量的平均值
        let maxV: Float = (recorder?.peakPower(forChannel: 0))! //获取音量最大值
        let lowPassResult: Double = pow(Double(10), Double(0.05 * maxV))
        let level = Int(Float((lowPassResult * 100)) / 20);
        
        volumeLevel = NSInteger(level + 1)
        if state == BXPChatSoundsRecorderState.recording {
            
            tipView.updateTipsImageWithVoiceVolumnLever(voiceVolumnLever: volumeLevel)
        }
//        print("volumeLevelChangeCheck---lowPassResult=\(lowPassResult)--level=\(level)")
    }
    
    var soundsRecordTimeCountNumber: NSInteger = 0
    @objc private func soundsRecordTimeCount() -> Void {

        soundsRecordTimeCountNumber = soundsRecordTimeCountNumber + 1
        if soundsRecordTimeCountNumber == 60 {
            state = BXPChatSoundsRecorderState.overTime
            stopRecording()
            return
        }
        if soundsRecordTimeCountNumber > 50 {
            if state == BXPChatSoundsRecorderState.recording {
                state = BXPChatSoundsRecorderState.recordingOnCountingDown
            }
            if state == BXPChatSoundsRecorderState.willCancel {
                state = BXPChatSoundsRecorderState.willCancelOnCountingDown
            }
            
            if state == BXPChatSoundsRecorderState.recordingOnCountingDown {
                tipView.updateTipsMessageState(state: BXPSoundsRecordTipViewState.countingDown)
                return
            } else {
                tipView.updateTipsMessageState(state: BXPSoundsRecordTipViewState.countingDownWillCancel)
            }
            tipView.updateTipsMessageCountingDown(countNumber: 60 - soundsRecordTimeCountNumber)
            
        }
    }
    
    func deleteSoundsFile() -> Void {

        if recorder == nil || recorder?.url == nil || recorder?.url.path == nil {
            return
        }
        if FileManager.default.fileExists(atPath: (recorder?.url.path)!) {
            if (recorder?.isRecording)! {
                recorder?.stop()
            }
            recorder?.deleteRecording()
        }
    }
    
    func startRecord() -> Void {
        state = BXPChatSoundsRecorderState.ready
        initMicrophone()
    }
    func willCancelRecording() -> Void {
        if state == BXPChatSoundsRecorderState.ready {
            return
        }
        if state == BXPChatSoundsRecorderState.recordingOnCountingDown {
            state = BXPChatSoundsRecorderState.willCancelOnCountingDown
            tipView.updateTipsMessageState(state: BXPSoundsRecordTipViewState.countingDownWillCancel)
            return
        }
        state = BXPChatSoundsRecorderState.willCancel
        tipView.updateTipsMessageState(state: BXPSoundsRecordTipViewState.willCancel)
    }
    func continueRecording() -> Void {
        
        if state == BXPChatSoundsRecorderState.ready {
            return
        }
        if state == BXPChatSoundsRecorderState.willCancelOnCountingDown {
            state = BXPChatSoundsRecorderState.recordingOnCountingDown
            tipView.updateTipsMessageState(state: BXPSoundsRecordTipViewState.countingDown)
            return
        }
        state = BXPChatSoundsRecorderState.recording
        tipView.updateTipsMessageState(state: BXPSoundsRecordTipViewState.normalRecording)
        tipView.updateTipsImageWithVoiceVolumnLever(voiceVolumnLever: volumeLevel)
    }
    
    func stopRecording() -> Void {
        if state != BXPChatSoundsRecorderState.ready {
            
            recorder?.stop()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch {
            }

            volumeLeverCheckTimer.invalidate()
            volumeLeverCheckTimer = nil
            
            soundsRecordTimeCountTimer.invalidate()
            soundsRecordTimeCountTimer = nil
            
            if beginDate == nil {
                return
            }
            
            let recorderTime: TimeInterval = Date().timeIntervalSince(beginDate!)
            if recorderTime < 0.8 {
                tipView.updateSoundsRecordTipViewWithTimeTooShort()
            }
            
            if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatSoundsRecorderDeleagte.chatSoundsRecorderDidFinishedRecordSounds(soundsPath:duration:))))! {
                delegate?.chatSoundsRecorderDidFinishedRecordSounds!(soundsPath: soundsSavePath, duration: recorderTime)
            }
            
            if state == BXPChatSoundsRecorderState.overTime {
                return
            }
            tipView.hidenTipView()
        }
        state = BXPChatSoundsRecorderState.finished
    }
    func cancelRecording() -> Void {
        if state != BXPChatSoundsRecorderState.ready {
        
            recorder?.stop()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
                print("stop!!")
            } catch {
            }
            
            volumeLeverCheckTimer.invalidate()
            volumeLeverCheckTimer = nil
            
            soundsRecordTimeCountTimer.invalidate()
            soundsRecordTimeCountTimer = nil
            
            deleteSoundsFile()
            
            if state == BXPChatSoundsRecorderState.overTime {
                return
            }
            tipView.hidenTipView()
        }
        state = BXPChatSoundsRecorderState.canceled
    }
}
