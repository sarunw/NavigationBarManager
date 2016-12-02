//
//  Helpers.swift
//  Pods
//
//  Created by Sarun Wongpatcharapakorn on 12/1/16.
//
//

import Foundation

// http://stackoverflow.com/questions/12991935/how-to-programmatically-get-ios-status-bar-height/16598350#16598350
func statusBarHeight() -> CGFloat {
    
    let statusBarSize = UIApplication.shared.statusBarFrame.size
    return min(statusBarSize.width, statusBarSize.height)
}
