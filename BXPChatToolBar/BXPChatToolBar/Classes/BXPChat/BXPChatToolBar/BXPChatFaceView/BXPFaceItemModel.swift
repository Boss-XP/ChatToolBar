//
//  BXPFaceItem.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/13.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import UIKit

class BXPFaceItemModel: NSObject {

    var imageIndex: NSNumber = 0;
    
//    func faceImage() -> UIImage? {
//        
//        var index = imageIndex.intValue//NSNumber() as! Integer
//        index += 1
//        
//        let subPath = NSString(format: "%d.png", index)//imageIndex + ".png"
//        
//        let iamgePath = Bundle.main.path(forResource: subPath as String, ofType: nil)! as String
//        
//        let image = UIImage(contentsOfFile: iamgePath)
//        
//        return image
//    }
    
    lazy var faceImage: UIImage = {
        var index = self.imageIndex.intValue//NSNumber() as! Integer
        index += 1
        
        let subPath = NSString(format: "%d.png", index)//imageIndex + ".png"
        
        let imagePath = Bundle.main.path(forResource: subPath as String, ofType: nil)! as String
        
        let tempImage = UIImage(contentsOfFile: imagePath)
        return tempImage!
    }()
    
}
