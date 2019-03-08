//
//  LPPageItem.swift
//  LPPageViewController
//
//  Created by 李鹏 on 2016/10/21.
//  Copyright © 2016年 李鹏. All rights reserved.
//

import UIKit

class LPPageItem: UIButton {
    
    /// item在PageBar中的index，此属性不能手动设置
    lazy var index: Int = 0
    
    /// 字体宽
    var titleWidth: CGFloat = 0.0
    
    /// 缩放后的字体宽
    var scaleTitleWidth: CGFloat = 0.0
    
    /// 设置item标题
    var title: String = "" {
        didSet {
            self.setTitle(title, for: .normal)
            self.setTitleWidth()
        }
    }
    
    /// 设置正常状态下的item字体颜色
    var titleColor: UIColor? {
        didSet {
            self.setTitleColor(titleColor, for: .normal)
        }
    }
    
    /// 设置item被选中后的字体颜色
    var titleSelectedColor: UIColor? {
        didSet {
            self.setTitleColor(titleSelectedColor, for: .selected)
        }
    }
    
    /// 设置item的字体大小
    var titleFont: UIFont? {
        didSet {
            self.titleLabel?.font = titleFont
            self.setTitleWidth()
        }
    }
    
    /// 设置item字体宽度
    fileprivate func setTitleWidth() {
        if let titleFont = self.titleLabel?.font, title.count > 0 {
            let width = (title as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                                         options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                         attributes: [.font: titleFont],
                                                         context: nil).size.width
            self.titleWidth = width
            self.scaleTitleWidth = width
        }
    }
    
    deinit {
        print("LPPageItem -> release memory.")
    }
}
