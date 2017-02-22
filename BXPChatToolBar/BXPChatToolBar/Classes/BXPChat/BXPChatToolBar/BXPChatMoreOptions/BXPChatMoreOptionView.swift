//
//  BXPChatMoreOptionView.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/23.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit
import AVFoundation
//import AVKit
import Photos

private let kCameraButtonImage = "chat_paizhao";
private let kPhotoButtonImage = "chat_photo";
private let kVideoButtonImage = "chat_move";
private let kFileButtonImage = "chat_file";

private let ChatMoreOptionsNameKey = "name";
private let ChatMoreOptionsImageKey = "imageName";

private let maxCountsPerPage: NSInteger = 6;

@objc protocol BXPChatMoreOptionViewDelegate : NSObjectProtocol{

    @objc optional func chatMoreOptionViewEndEditingWithChatMoreOptionViewCellClicked() -> Void;
    @objc optional func chatMoreOptionViewDidFinishedGetImage(image: UIImage, thumbImage: UIImage, isOriginal: Bool) -> Void
    @objc optional func chatMoreOptionViewDidFinishedRecordVideo(videoPath: String, thumbImage: UIImage, duration: TimeInterval) -> Void
}

class BXPChatMoreOptionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BXPVideoRecordViewControllerDelegate {
    
    var delegate: BXPChatMoreOptionViewDelegate?
    

    private let options = [
                    [ChatMoreOptionsNameKey : "相机", ChatMoreOptionsImageKey : kCameraButtonImage],
                    [ChatMoreOptionsNameKey : "相册", ChatMoreOptionsImageKey : kPhotoButtonImage],
                    [ChatMoreOptionsNameKey : "小视频", ChatMoreOptionsImageKey : kVideoButtonImage],
//                    [ChatMoreOptionsNameKey:@"文件", ChatMoreOptionsImageKey:kVideoButtonImage]
    ]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 242/255.0, green: 244/255.0, blue: 248/255.0, alpha: 1.0)
        var sizeFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 216)
        
        if options.count <= Int(maxCountsPerPage / 2) {
            sizeFrame.size.height = 116
        }
        self.frame = sizeFrame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(collectionView)
        
    }
    
    // MARK: - lazy
    let deleteCellIdentifier = "chat.more.options.cell"
    
    private lazy var collectionView: UICollectionView = {
        var frame: CGRect = self.bounds
        frame.size.height -= 16;
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumLineSpacing = 0;//水平间距
        layout.minimumInteritemSpacing = 0;//竖直间距
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)//UIEdgeInsetsMake(10, 10, 8, 10);
        
        let tempCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        tempCollectionView.backgroundColor = UIColor(red: 242/255.0, green: 244/255.0, blue: 248/255.0, alpha: 1.0)
        tempCollectionView.dataSource = self
        tempCollectionView.delegate = self
        //        tempCollectionView.isPrefetchingEnabled = false
        tempCollectionView.isPagingEnabled = true
        tempCollectionView.showsHorizontalScrollIndicator = false
        tempCollectionView.register(BXPChatMoreOptionCollectionViewCell.self, forCellWithReuseIdentifier: self.deleteCellIdentifier)
        return tempCollectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let tempPage = UIPageControl()
        
        tempPage.pageIndicatorTintColor = UIColor.init(red: 135/255, green: 136/255, blue: 142/255, alpha: 1.0)
        tempPage.currentPageIndicatorTintColor = UIColor.init(red: 29/255, green: 29/255, blue: 36/255, alpha: 1.0)
        tempPage.currentPage = 0
        
        tempPage.numberOfPages = Int(self.options.count / maxCountsPerPage)
        tempPage.isHidden = !(tempPage.numberOfPages > 1)
        
        tempPage.translatesAutoresizingMaskIntoConstraints = false
        return tempPage
    }()
    
    private func makeConstrainsForPageControl() -> Void {
        let centerXConstraint = NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: collectionView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
        
        let heightConstraint = NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 16)
        let widthConstraint = NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 50)
        
        self.addConstraints([centerXConstraint, bottomConstraint])
        pageControl.addConstraints([heightConstraint, widthConstraint])
    }
    
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(options.count / maxCountsPerPage + 1)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let counts = options.count - section * maxCountsPerPage
        return (counts > maxCountsPerPage) ? maxCountsPerPage : counts
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deleteCellIdentifier, for: indexPath) as! BXPChatMoreOptionCollectionViewCell
        let optionInfo = options[indexPath.row + indexPath.section * maxCountsPerPage] as Dictionary
        
//        cell.backgroundColor = UIColor.white
        cell.setupOptionsWith(title: optionInfo[ChatMoreOptionsNameKey]!, imageName: optionInfo[ChatMoreOptionsImageKey]!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatMoreOptionViewDelegate.chatMoreOptionViewEndEditingWithChatMoreOptionViewCellClicked)))! {
            delegate?.chatMoreOptionViewEndEditingWithChatMoreOptionViewCellClicked!()
        }
        switch indexPath.row {
            case 0:
                takePhotoWithCamera()
                break
            
            case 1:
                pickPictureFromPhotoLibrary()
                break
                
            case 2:
                showVideoRecordingView()
                break
            
            default:
                break
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    let sizeW: CGFloat = UIScreen.main.bounds.size.width / CGFloat(maxCountsPerPage / 2)
    let sizeH: CGFloat = 100
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: sizeW, height: sizeH)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.15, animations: {
            self.pageControl.currentPage = Int(scrollView.contentOffset.x / self.bounds.size.width)
        })
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            
            UIView.animate(withDuration: 0.15, animations: {
                self.pageControl.currentPage = Int(scrollView.contentOffset.x / self.bounds.size.width)
            })
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let type: String = (info[UIImagePickerControllerMediaType] as! String)
        //当选择的类型是图片
        if type=="public.image"
        {
            let img = info[UIImagePickerControllerOriginalImage] as? UIImage
            let editImageVC = BXPImageEditViewController(image: img!, sendHandler: { (image: UIImage, thumbImage: UIImage, isOriginal: Bool) in
                
                if (self.delegate != nil) && (self.delegate?.responds(to: #selector(BXPChatMoreOptionViewDelegate.chatMoreOptionViewDidFinishedGetImage(image:thumbImage:isOriginal:))))! {
                    self.delegate?.chatMoreOptionViewDidFinishedGetImage!(image: image, thumbImage: thumbImage, isOriginal: isOriginal)
                }
            })//(image: img!)
            
            picker.pushViewController(editImageVC, animated: true)
            return
        }
        picker.dismiss(animated:true, completion:nil)
    }

    //MARK: - BXPVideoRecordViewControllerDelegate
    func videoRecordPathForVideoSave() -> String {
        return ""
    }

    func videoRecordDidFinishedRecordVideo(videoPath: String, thumbImage: UIImage, duration: TimeInterval) {
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatMoreOptionViewDelegate.chatMoreOptionViewDidFinishedRecordVideo(videoPath:thumbImage:duration:))))! {
            delegate?.chatMoreOptionViewDidFinishedRecordVideo!(videoPath: videoPath, thumbImage: thumbImage, duration: duration)
        }
    }

    //MARK: - permission
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
    
    private func isPhotosAuthorityOn() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.restricted || status == PHAuthorizationStatus.denied {
            return false
        }
        return true
    }
    
    func takePhotoWithCamera() -> Void {
        if !isCameraAuthorityOn() {
            showNoPermission(title: "打开相机失败", subTitle: "相机")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        AppDelegate.shareInstance().topViewController().present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPictureFromPhotoLibrary() -> Void {
        if !isPhotosAuthorityOn() {
            showNoPermission(title: "打开相册失败", subTitle: "相册")
            return
        }
        let switchmm = UISwitch(frame: CGRect(x: 10, y: 80, width: 50, height: 50))
        AppDelegate.shareInstance().topViewController().view.addSubview(switchmm)
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        AppDelegate.shareInstance().topViewController().present(imagePicker, animated: true, completion: nil)
    }
    
    func showVideoRecordingView() -> Void {
        if !isCameraAuthorityOn() {
            showNoPermission(title: "打开相机失败", subTitle: "相机")
            return
        }

        if !isMicrophomeAuthorityOn() {
            showNoPermission(title: "打开麦克风失败", subTitle: "麦克风")
            return
        }

        let videoVC = BXPVideoRecordViewController()
        videoVC.delegate = self
        AppDelegate.shareInstance().topViewController().addChildViewController(videoVC)
        AppDelegate.shareInstance().topViewController().view.addSubview(videoVC.view)
        videoVC.view.transform = CGAffineTransform(translationX: 0, y: 380)
        UIView.animate(withDuration: 0.6) {
            videoVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }

    func showNoPermission(title: String, subTitle: String) -> Void {

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

}
