//
//  BXPChatFaceView.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/13.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

private let kFooterViewHeight: CGFloat = 50
private let kViewMargin: CGFloat = 20
private let kCountsPerPage: NSInteger = 20

private let kEmojiImageKey = "emoji"
private let kDeleteEmojiImageKey = "chat_face_delete"

@objc
protocol BXPChatFaceViewDelegate: NSObjectProtocol {
    @objc optional func chatFaceView(_ chatFaceView: BXPChatFaceView, didSelected item: BXPFaceItemModel) -> Void
    @objc optional func chatFaceViewDidClikcedDeleteItem(_ chatFaceView: BXPChatFaceView) -> Void
    @objc optional func chatFaceViewDidSendButton(_ chatFaceView: BXPChatFaceView) -> Void
}


class BXPChatFaceView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let emojiCellIdentifier = "chat.face.cell.emoji"
    let deleteCellIdentifier = "chat.face.cell.delete"
    
    var faceImages = [Any]()//[Any]?.self
    
    weak var delegate: BXPChatFaceViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let path = Bundle.main.path(forResource: "ChatSystemFaceConfig.plist", ofType: nil)
        let faces = (NSArray(contentsOfFile: path!) as! Array<Any>)
        //(NSArray(contentsOfFile: path!) as! Array<Any>)
        
        for (_, value) in faces.enumerated() {
            let dict = value as! Dictionary<String, Any>
            let emojiIndex = dict["emojiIndex"] as? NSNumber
            let itemModel = BXPFaceItemModel()
            
            itemModel.imageIndex = emojiIndex ?? 0
//            faceImages += [emojiIndex ?? 0]
            faceImages += [itemModel]
//            faceImages.append([emojiIndex])
        }
        
        var frameValue = frame
        frameValue.size.height = 216;
        self.frame = frameValue;
        
        setupBottomView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(collectionView)
        addSubview(pageControl)
        
        makeConstrainsForPageControl()
    }

    
    func setupBottomView() -> Void {
        let height: CGFloat = 35
        
        let bottomView = UIView(frame: CGRect(x: 0, y: self.bounds.size.height - height, width: UIScreen.main.bounds.size.width, height: height))
        bottomView.backgroundColor = UIColor.white
        addSubview(bottomView)
    
        let width: CGFloat = 66
        let edgeInset:CGFloat = (width - height) * 0.5
        
        let emojiButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        emojiButton.setImage(UIImage(named: kEmojiImageKey), for: UIControlState.normal)
        emojiButton.imageEdgeInsets = UIEdgeInsetsMake(0, edgeInset, 0, edgeInset)
        emojiButton.backgroundColor = UIColor(red: 242/255.0, green: 244/255.0, blue: 248/255.0, alpha: 1.0)
        bottomView.addSubview(emojiButton)
        
        let sendButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - width, y: 0, width: width, height: height))
        sendButton.setTitle("发送", for: UIControlState.normal)
        sendButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        sendButton.backgroundColor = UIColor(red: 0/255.0, green: 198/255.0, blue: 129/255.0, alpha: 1.0)
        sendButton.addTarget(self, action: #selector(self.sendButtonClicked), for: UIControlEvents.touchUpInside)
        bottomView.addSubview(sendButton)
    }
    
    private lazy var collectionView: UICollectionView = {
        var frame: CGRect = self.bounds
        frame.size.height -= 35;
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumLineSpacing = 0;//水平间距
        layout.minimumInteritemSpacing = 0;//竖直间距
        layout.sectionInset = UIEdgeInsetsMake(8, 10, 23, 10)//UIEdgeInsetsMake(10, 10, 8, 10);

        let tempCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        tempCollectionView.backgroundColor = UIColor(red: 242/255.0, green: 244/255.0, blue: 248/255.0, alpha: 1.0)
        tempCollectionView.dataSource = self
        tempCollectionView.delegate = self
//        tempCollectionView.isPrefetchingEnabled = false
        tempCollectionView.isPagingEnabled = true
        tempCollectionView.showsHorizontalScrollIndicator = false
        tempCollectionView.register(BXPChatFaceCollectionViewCell.self, forCellWithReuseIdentifier: self.emojiCellIdentifier)
        tempCollectionView.register(BXPChatFaceCollectionViewCell.self, forCellWithReuseIdentifier: self.deleteCellIdentifier)
        return tempCollectionView
    }()
    
    lazy var pageControl: UIPageControl = {
        let tempPage = UIPageControl()

        tempPage.pageIndicatorTintColor = UIColor.init(red: 135/255, green: 136/255, blue: 142/255, alpha: 1.0)
        tempPage.currentPageIndicatorTintColor = UIColor.init(red: 29/255, green: 29/255, blue: 36/255, alpha: 1.0)
        tempPage.currentPage = 0
        
        tempPage.numberOfPages = Int(self.faceImages.count / kCountsPerPage)
        tempPage.isHidden = !(tempPage.numberOfPages > 1)
        
        tempPage.translatesAutoresizingMaskIntoConstraints = false
        return tempPage
    }()
    
    func makeConstrainsForPageControl() -> Void {
        let centerXConstraint = NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: collectionView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: collectionView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -20)
        
        let heightConstraint = NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 15)
        let widthConstraint = NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 50)
        
        self.addConstraints([centerXConstraint, topConstraint])
        pageControl.addConstraints([heightConstraint, widthConstraint])
    }
    
    // MARK: - Events Response
    func sendButtonClicked() -> Void {
        
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatFaceViewDelegate.chatFaceViewDidSendButton(_:))))! {
            delegate?.chatFaceViewDidSendButton!(self)
        }
    }

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(faceImages.count / kCountsPerPage)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(kCountsPerPage + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == kCountsPerPage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: deleteCellIdentifier, for: indexPath) as! BXPChatFaceCollectionViewCell
            cell.setupDeleteItemWithImage(image: UIImage(named: kDeleteEmojiImageKey)!)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellIdentifier, for: indexPath) as! BXPChatFaceCollectionViewCell
            let itemModel = faceImages[indexPath.row + kCountsPerPage * indexPath.section] as! BXPFaceItemModel

            cell.setupFaceImageWithImage(image: itemModel.faceImage)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == kCountsPerPage {
            if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatFaceViewDelegate.chatFaceViewDidClikcedDeleteItem(_:))))! {
                delegate?.chatFaceViewDidClikcedDeleteItem!(self)
            }
            return
        }
        
        if (delegate != nil) && (delegate?.responds(to: #selector(BXPChatFaceViewDelegate.chatFaceViewDidClikcedDeleteItem(_:))))! {
            let itemModel = faceImages[indexPath.row + kCountsPerPage * indexPath.section] as! BXPFaceItemModel
            delegate?.chatFaceView!(self, didSelected: itemModel)
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    let sizeW: CGFloat = (UIScreen.main.bounds.size.width - kViewMargin) / 7.0
    let sizeH: CGFloat = (216 - kViewMargin - kFooterViewHeight) / 3
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
}
