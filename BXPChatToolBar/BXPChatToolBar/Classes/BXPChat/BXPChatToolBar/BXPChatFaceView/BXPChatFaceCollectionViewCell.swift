//
//  BXPChatFaceCollectionViewCell.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/13.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

class BXPChatFaceCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(faceImage)
        
        faceImage.center = self.contentView.center
    }
    
    func setupFaceImageWithImage(image:UIImage) -> Void {
        faceImage.image = image
    }
    
    func setupDeleteItemWithImage(image: UIImage) -> Void {
        faceImage.image = image
        faceImage.frame.size.width = 31
        faceImage.frame.size.height = 21
    }
    
    
    private lazy var faceImage: UIImageView = {
        let tempImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))

        return tempImageView
    }()

}
