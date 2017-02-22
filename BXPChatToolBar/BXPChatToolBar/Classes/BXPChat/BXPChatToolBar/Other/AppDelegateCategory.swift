//
//  AppDelegateCategory.swift
//  BXPChatToolBar
//
//  Created by 向攀 on 17/1/20.
//  Copyright © 2017年 Yunyun Network Technology Co,Ltd. All rights reserved.
//

import Foundation

extension AppDelegate {

    class func shareInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func getTopViewController(_ currentViewController: UIViewController) -> UIViewController {
        if currentViewController.isKind(of: UINavigationController.self) {
            if (currentViewController.presentedViewController != nil) {
                return self.getTopViewController(currentViewController.presentedViewController!)
            }
            let navVC = currentViewController as! UINavigationController
            let navTop = navVC.topViewController
            if navTop == nil {
                return navVC
            }
            if ((navTop?.presentedViewController) != nil) {
                return self.getTopViewController((navTop?.presentedViewController)!)
            }
            return navTop!
        }
        if currentViewController.isKind(of: UITabBarController.self) {
            let tabBarVC = currentViewController as! UITabBarController
            let selectedVC = tabBarVC.selectedViewController
            if selectedVC == nil {
                return tabBarVC
            }
            return self.getTopViewController(selectedVC!)
        }
        if (currentViewController.presentedViewController != nil) {
            return self.getTopViewController(currentViewController.presentedViewController!)
        }
        return currentViewController
    }
    
    func topViewController() -> UIViewController {

        return self.getTopViewController((UIApplication.shared.keyWindow?.rootViewController)!)
    }
    
    func enableNavigationPopGesture() -> Void {
        
        if topViewController().navigationController != nil {
            topViewController().navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    func disableNavigationPopGesture() -> Void {
        
        if topViewController().navigationController != nil {
            topViewController().navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}

