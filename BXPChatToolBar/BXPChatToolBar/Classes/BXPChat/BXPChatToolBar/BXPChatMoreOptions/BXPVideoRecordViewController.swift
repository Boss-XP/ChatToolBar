//
//  BXPVideoRecordViewController.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/22.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

@objc protocol BXPVideoRecordViewControllerDelegate: NSObjectProtocol {
    @objc optional func videoRecordPathForVideoSave() -> String
    @objc optional func videoRecordDidFinishedRecordVideo(videoPath: String, thumbImage: UIImage, duration: TimeInterval) -> Void
}

class BXPVideoRecordViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, BXPChatVideoRecordOptionsViewDelegate {
    private let switchCameraImageNameKey = "switch_camera"

    var delegate: BXPVideoRecordViewControllerDelegate?
    private var videoSavePath = ""
    private var thumbImage: UIImage?
    private var videoDuration: TimeInterval = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupVideoRecorder()
        videoContainerView.addSubview(switchCameraButton)
        
        AppDelegate.shareInstance().disableNavigationPopGesture()  
    }
    
    private func setupUI() -> Void {

        view.addSubview(videoContainerView)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.settingFocusCorsor(_:)))
        videoContainerView.addGestureRecognizer(tapGes)
        
        
        let viewHeight: CGFloat = 88
        
        let recordOptionsView = BXPChatVideoRecordOptionsView(frame: CGRect(x: 0, y: view.bounds.size.height - viewHeight, width: view.bounds.size.width, height: viewHeight))
        recordOptionsView.delegate = self
        view.addSubview(recordOptionsView)
        
        view.addSubview(upToCancelButton)
        view.addSubview(focusView)
    }
    
    
    private let captureSession = AVCaptureSession()
    private var videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    private let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    private let fileOutput = AVCaptureMovieFileOutput()
    
    //最大允许的录制时间（秒）
    private let totalSeconds: Float64 = 15.00
    //每秒帧数
    private var framesPerSecond:Int32 = 30
    
    //保存所有的录像片段数组
    private var videoAssets = [AVAsset]()
    //保存所有的录像片段url数组
    private var assetURLs = [String]()
    
    private var videoInput: AVCaptureInput?
    private var videoShowLayer: AVCaptureVideoPreviewLayer?
    private var isFocusing = false
    
    
    private func setupVideoRecorder() -> Void {
    
        //添加视频、音频输入设备
        videoInput = try! AVCaptureDeviceInput(device: videoDevice)
        captureSession.addInput(videoInput)
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice)
        captureSession.addInput(audioInput);
        
        //添加视频捕获输出
        let maxDuration = CMTimeMakeWithSeconds(totalSeconds, framesPerSecond)
        self.fileOutput.maxRecordedDuration = maxDuration
        self.captureSession.addOutput(self.fileOutput)
        
        //使用AVCaptureVideoPreviewLayer可以将摄像头的拍摄的实时画面显示在ViewController上
        let videoLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        //预览窗口是正方形，在屏幕居中（显示的也是摄像头拍摄的中心区域）
        videoLayer?.frame = CGRect(x: 0, y: 0, width: videoContainerView.bounds.size.width, height: videoContainerView.bounds.size.height)
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
//        videoLayer?.pointForCaptureDevicePointOfInterest(CGPoint(x: 0, y: 0))
        videoContainerView.layer.addSublayer(videoLayer!)
        videoShowLayer = videoLayer
        captureSession.startRunning()
    }
    
    // MARK: - Setting
    private func getCameraDeviceWithPosition(position:AVCaptureDevicePosition) -> AVCaptureDevice{
        let cameras = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for camera in cameras! {
            if (camera as AnyObject).position == position {
                return camera as! AVCaptureDevice
            }
        }
        return cameras!.first as! AVCaptureDevice
    }

    
    private func setFocusCursorWithPoint(point:CGPoint){

        if isFocusing {
            return
        }
        
        isFocusing = true
        focusView.center = point
        focusView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        focusView.frame = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
        focusView.isHidden = false
        
        UIView.animate(withDuration: 0.8, animations: { 
            self.focusView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.focusView.alpha = 1
        }) { (isFinished: Bool) in
            if !isFinished {
                self.focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.focusView.alpha = 1
            } else {
                UIView.animate(withDuration: 0.5, delay: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { 
                    self.focusView.alpha = 0
                }, completion: { (finished: Bool) in
                    self.focusView.isHidden = true
                    self.focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.isFocusing = false
                })
            }
        }
    }
    
    //设置焦点
    private func focusWithMode(focusModel:AVCaptureFocusMode,exposureMode:AVCaptureExposureMode,point:CGPoint){
        changeDeviceProperty { (captureDevice) -> Void in
            if captureDevice.isFocusModeSupported(focusModel) {
                captureDevice.focusMode = focusModel
            }
            if captureDevice.isExposureModeSupported(exposureMode) {
                captureDevice.exposureMode = exposureMode
            }
            captureDevice.exposurePointOfInterest = point
            captureDevice.focusPointOfInterest = point
        }
    }
    
    //改变设备属性的统一操作方法
    private func changeDeviceProperty(closure :(_ captureDevice:AVCaptureDevice) -> Void) {
        let cDevice = videoDevice
        do {
            
            try cDevice?.lockForConfiguration()
            closure(cDevice!)
            cDevice?.unlockForConfiguration()
        } catch {
            print("设置设备属性的过程中发生错误")
        }
    }
    
    private func isFrontCamera() -> Bool {
        
        let currentDevice = videoDevice
        let currentPosition = currentDevice?.position
        
        if currentPosition == AVCaptureDevicePosition.unspecified || currentPosition == AVCaptureDevicePosition.front {
            return true
        }
        return false
    }
    
    // MARK: - Getter
    private lazy var videoContainerView: UIView = {
        let viewFrame = UIScreen.main.bounds
        let viewHeight: CGFloat = 360
        let tempView = UIView(frame: CGRect(x: 0, y: viewFrame.size.height - viewHeight, width: viewFrame.size.width, height: viewHeight))
        tempView.backgroundColor = UIColor.red
        return tempView
    }()
    
    private lazy var switchCameraButton: UIButton = {
        let buttonW: CGFloat = 72
        let buttonH: CGFloat = 50
        let buttonFrame = CGRect(x: self.videoContainerView.bounds.size.width - buttonW, y: 10, width: buttonW, height: buttonH)
        let tempButton = UIButton(frame: buttonFrame)
        tempButton.setImage(UIImage(named: self.switchCameraImageNameKey), for: UIControlState.normal)
        tempButton.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10)
        tempButton.addTarget(self, action: #selector(self.switchCacmer), for: UIControlEvents.touchUpInside)
        
        return tempButton
    }()
    

    private lazy var upToCancelButton: UIButton = {

        let buttonWidth: CGFloat = 100
        
        let tempButton = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width - buttonWidth) * 0.5, y: 10 + UIScreen.main.bounds.height - self.videoContainerView.frame.size.height, width: buttonWidth, height: 35))
        tempButton.isUserInteractionEnabled = false
        
        tempButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        
        tempButton.setImage(UIImage(named: "record_upbutton"), for: UIControlState.normal)
        tempButton.setTitle(" 上划取消", for: UIControlState.normal)
        
        tempButton.setImage(UIImage(named: "record_cancelbutton"), for: UIControlState.selected)
        tempButton.setTitle(" ", for: UIControlState.selected)

        tempButton.isHidden = true
        return tempButton
    }()
    
    private lazy var focusView: UIImageView = {
        let tempView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        tempView.image = UIImage(named: "record_focusbutton")
        tempView.isHidden = true
        return tempView
    }()
    

    // MARK: - events response
    @objc private func switchCacmer() -> Void {
        
        let currentDevice = videoDevice//captureDeviceInput.device//获得设备
        let currentPosition = currentDevice?.position//获得设备位置
        
        var toChangePosition = AVCaptureDevicePosition.front
        if currentPosition == AVCaptureDevicePosition.unspecified || currentPosition == AVCaptureDevicePosition.front {
            
            toChangePosition = AVCaptureDevicePosition.back
        }
        let toChangeDevice = getCameraDeviceWithPosition(position: toChangePosition)
        
        //获得要调整的输入对象
        var toChangeDeviceInput :AVCaptureDeviceInput!
        do {
            toChangeDeviceInput = try AVCaptureDeviceInput(device: toChangeDevice)
        } catch {}
        
        captureSession.beginConfiguration()
        
        captureSession.removeInput(videoInput)
        videoDevice = toChangeDevice
        //添加新的输入对象
        if captureSession.canAddInput(toChangeDeviceInput){
            captureSession.addInput(toChangeDeviceInput)
            videoInput = toChangeDeviceInput
        }
        captureSession.commitConfiguration()//提交会话配置
    }
    
    //手势获取焦点
    @objc private func settingFocusCorsor(_ tap:UITapGestureRecognizer){
        
        if isFrontCamera() {
            return
        }
        
        let point = tap.location(in: tap.view)
        
        //将UI坐标转化为摄像头坐标
        let cameraPoint = videoShowLayer?.captureDevicePointOfInterest(for: point)
        
        setFocusCursorWithPoint(point: videoContainerView.convert(point, to: view))
        focusWithMode(focusModel: .autoFocus, exposureMode:.autoExpose, point: cameraPoint!)
    }
    
    
    // MARK: - 视频处理
    private func mergeVideos() -> Void{
        let duration = totalSeconds
        
        let composition = AVMutableComposition()
        //合并视频、音频轨道
        let firstTrack = composition.addMutableTrack(
            withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        let audioTrack = composition.addMutableTrack(
            withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        var insertTime: CMTime = kCMTimeZero
        for asset in videoAssets {
//            print("合并视频片段：\(asset)")
            do {
                try firstTrack.insertTimeRange(
                    CMTimeRangeMake(kCMTimeZero, asset.duration),
                    of: asset.tracks(withMediaType: AVMediaTypeVideo)[0] ,
                    at: insertTime)
            } catch _ {
            }
            do {
                try audioTrack.insertTimeRange(
                    CMTimeRangeMake(kCMTimeZero, asset.duration),
                    of: asset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                    at: insertTime)
            } catch _ {
            }
            
            insertTime = CMTimeAdd(insertTime, asset.duration)
        }
        //旋转视频图像，防止90度颠倒
        firstTrack.preferredTransform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        
        //定义最终生成的视频尺寸（矩形的）
//        print("视频原始尺寸：", firstTrack.naturalSize)
        let renderSize = CGSize(width: firstTrack.naturalSize.height, height: firstTrack.naturalSize.height)//CGSizeMake(firstTrack.naturalSize.height, firstTrack.naturalSize.height)
//        print("最终渲染尺寸：", renderSize)
        
        //通过AVMutableVideoComposition实现视频的裁剪(矩形，截取正中心区域视频)
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, framesPerSecond)
        videoComposition.renderSize = renderSize
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(
            kCMTimeZero,CMTimeMakeWithSeconds(Float64(duration), framesPerSecond))
        
        let transformer: AVMutableVideoCompositionLayerInstruction =
            AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack)
        let t1 = CGAffineTransform(translationX: firstTrack.naturalSize.height,
                                   y: -(firstTrack.naturalSize.width-firstTrack.naturalSize.height)/2)
        let t2 = t1.rotated(by: CGFloat(M_PI_2))
        let finalTransform: CGAffineTransform = t2
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        //设置合并后的视频路径
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPVideoRecordViewControllerDelegate.videoRecordPathForVideoSave)))! {
            videoSavePath = (delegate?.videoRecordPathForVideoSave!())!
        }
        let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask,true)[0]
        let dataStr = Date().timeIntervalSinceReferenceDate

        let destinationPath = (videoSavePath.characters.count > 1) ? videoSavePath : (cachesPath + "/chatToolBar-shortvideo-\(dataStr)-video.mov")
//        print("合并后的视频：\(destinationPath)")
        let videoPath: NSURL = NSURL(fileURLWithPath: destinationPath as String)
        
        //视频质量
        let exporter = AVAssetExportSession(asset: composition,
                                            presetName:AVAssetExportPreset640x480)!//AVAssetExportPresetHighestQuality
        exporter.outputURL = videoPath as URL
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.videoComposition = videoComposition //设置videoComposition
        exporter.shouldOptimizeForNetworkUse = true
        exporter.timeRange = CMTimeRangeMake(
            kCMTimeZero,CMTimeMakeWithSeconds(Float64(duration), framesPerSecond))
        exporter.exportAsynchronously(completionHandler: {
            self.exportDidFinish(session: exporter)
        })
    }
    
    //将合并完成
    private func exportDidFinish(session: AVAssetExportSession) -> Void {
        
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPVideoRecordViewControllerDelegate.videoRecordDidFinishedRecordVideo(videoPath:thumbImage:duration:))))! {
            delegate?.videoRecordDidFinishedRecordVideo!(videoPath: videoSavePath, thumbImage: UIImage(named: "flash")!, duration: videoDuration)
//            delegate?.didFinishedRecordVideo!(videoPath: videoSavePath, thumbImage: UIImage(named: "")!, duration: 1.0)
        }
        
    }

    // MARK: - AVCaptureFileOutputRecordingDelegate-录视频代理
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        if isTimeTooShort {
            return
        }
        
        let asset : AVURLAsset = AVURLAsset(url: outputFileURL, options: nil)
        var duration : TimeInterval = 0.0
        duration = CMTimeGetSeconds(asset.duration)

        videoAssets.append(asset)
        assetURLs.append(outputFileURL.path)

        videoDuration = duration
        mergeVideos()
    }
    
    // MARK: - utility
    private func showDrawUpToCancelTipView() -> Void {
        upToCancelButton.isHidden = false
        upToCancelButton.isSelected = false
    }
    
    private func showTouchUpToCancelTipView() -> Void {
        upToCancelButton.isSelected = true
    }
    
    private func hideUpToCancelTipView() -> Void {
        upToCancelButton.isHidden = true
    }
    
    private func startRecording() -> Void {

        if !isCameraAuthorityOn() {
            showNoPermission(title: "打开相机失败", subTitle: "相机")
            return
        }

        if !isMicrophomeAuthorityOn() {
            showNoPermission(title: "打开麦克风失败", subTitle: "麦克风")
            return
        }

        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String

        let outputFilePath = "\(documentsDirectory)/output-shortvideo-1.mov"
        let outputURL = NSURL(fileURLWithPath: outputFilePath)
        let fileManager = FileManager.default
        if(fileManager.fileExists(atPath: outputFilePath)) {
            
            do {
                try fileManager.removeItem(atPath: outputFilePath)
            } catch _ {
            }
        }
//        print("开始录制：\(outputFilePath) ")
        fileOutput.startRecording(toOutputFileURL: outputURL as URL!, recordingDelegate: self)
    }

    private func isCameraAuthorityOn() -> Bool {

        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied {
            return false
        }
        return true
    }

    private func isMicrophomeAuthorityOn() -> Bool {

        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        if authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied {
            return false
        }
        return true
    }

    private func showNoPermission(title: String, subTitle: String) -> Void {

        let alertController = UIAlertController(title: title, message: "请在“设置-隐私-麦克风”中允许访问\(subTitle)", preferredStyle: .alert)
        //                    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default, handler:{
            (UIAlertAction) -> Void in

        })
        //                    alertView.addAction(cancelAction)
        alertController.addAction(okAction)
        let topVC = AppDelegate.shareInstance().topViewController()
        topVC.present(alertController, animated: true, completion: nil)
    }

    // MARK: - BXPChatVideoRecordOptionsViewDelegate
    func changeFlashLightStatus(isOn: Bool) {

        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if device == nil {
            return
        }
        if device?.torchMode == AVCaptureTorchMode.off{
            do {
                try device?.lockForConfiguration()
            } catch {
                return
            }
            device?.torchMode = .on
            device?.unlockForConfiguration()
        }else {
            do {
                try device?.lockForConfiguration()
            } catch {
                return
            }
            device?.torchMode = .off
            device?.unlockForConfiguration()
        }
    }
    
    func cancelButtonDidClicked() {
        
//        [[AppDelegate shareInstance] enableNavigationPopGesture];
        AppDelegate.shareInstance().enableNavigationPopGesture()
        
        DispatchQueue.main.async { 
            UIView.animate(withDuration: 0.5, animations: { 
                self.view.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.size.height)
            }, completion: { (isFinished: Bool) in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                
                //                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
                try? AVAudioSession.sharedInstance().setActive(false, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
            })
        }

        
    }
    
    private var beginDate: Date?
    func recordButtonTouchDown() {
        startRecording()
        showDrawUpToCancelTipView()
        beginDate = Date()
    }
    
    func recordButtonDragExit() {
        showTouchUpToCancelTipView()
    }
    
    func recordButtonDragEnter() {
        showDrawUpToCancelTipView()
    }
    
    func recordButtonTouchUpOutside() {
        fileOutput.stopRecording()

        hideUpToCancelTipView()
    }
    
    private var isTimeTooShort = false
    func recordButtonTouchUpInside() {
        
        let recordTime = Date().timeIntervalSince(beginDate!)
        if recordTime < 1 {
            isTimeTooShort = true
            
        } else {
            
            isTimeTooShort = false
        }
        
        fileOutput.stopRecording()
        hideUpToCancelTipView()
    }
    
    func finishedRecordWithOverTime() {
        fileOutput.stopRecording()
        hideUpToCancelTipView()
    }
}
