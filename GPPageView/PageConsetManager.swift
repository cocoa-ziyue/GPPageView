//
//  PageConsetManager.swift
//  GPPageView
//
//  Created by cocoaziyue on 2019/3/5.
//  Copyright © 2019年 cocoaziyue. All rights reserved.
//

import UIKit

class PageConsetManager: NSObject {
    static let shared = PageConsetManager()       //单例
    var lastConsetY: CGFloat = 0.0      //上一次的滑动位置
    var valueChanged: Bool = false      //发生改变
    
    override func copy() -> Any {
        return self
    }
    
    override func mutableCopy() -> Any {
        return self
    }
    
    func reset() {      //重置属性
        lastConsetY = 0.0
    }
}
