//
//  LPPageBar.swift
//  LPPageViewController
//
//  Created by 李鹏 on 2016/10/21.
//  Copyright © 2016年 李鹏. All rights reserved.
//

import UIKit

protocol LPPageBarDelegate: NSObjectProtocol {
    func pageBar(bar: LPPageBar, willSelectItemAt index: Int) -> Bool
    /// isReload = true 时为点击当前选中的item，触发刷新 -- 颜志伟
    func pageBar(bar: LPPageBar, didSelectedItemAt index: Int, isReload: Bool) -> Void
}

enum LPPageSelectionLineViewMode {
    case resizesToTextWidth // LineView的宽度将和item的宽保持相等
    case fillItem // LineView的宽带将填充整个item的宽
    case fixedWidth // 固定宽度 -- 邹海清
}

class LPPageBar: UIView {
    weak var delegate: LPPageBarDelegate?

    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.red
        return line
    }()
    var lineViewHeight: CGFloat = 4.0 {
        didSet {
            self.updateLineViewFrame(self.selectedItemIndex)
        }
    }
    var lineViewBottomOffset: CGFloat = 4.0 {
        didSet {
            self.updateLineViewFrame(self.selectedItemIndex)
        }
    }
    
    /// LPPageItem选中切换时，是否显示动画
    lazy var lineViewSwitchAnimated: Bool = true
    
    /// 当lineView匹配title的文字宽度时，左右留出的空隙，lineView的宽度 = 文字宽度 + spacing
    lazy var lineViewWidthWithSpacing: CGFloat = 0.0
    lazy var lineViewMode: LPPageSelectionLineViewMode = LPPageSelectionLineViewMode.resizesToTextWidth
    
    /// pageBar边缘与第一个和最后一个item的距离
    var leftAndRightSpacing: CGFloat = 0.0 {
        didSet {
            self.updateItemsFrame()
        }
    }
    
    /// 左右item之间的间隔
    var itemSpacing: CGFloat = 0.0 {
        didSet {
            self.updateItemsFrame()
        }
    }
    
    /// 返回已选中的item
    var selectedItem: LPPageItem? {
        get {
            if self.selectedItemIndex >= 0 && self.selectedItemIndex < self.items.count {
                return self.items[self.selectedItemIndex]
            }
            return nil
        }
    }
    
    var selectedItemIndex: Int = 1 {
        didSet {
            if self.items.count == 0 || selectedItemIndex < 0 || selectedItemIndex >= self.items.count {
                return
            }
            
            if oldValue >= 0 && oldValue < self.items.count {
                let oldSelectedItem = self.items[oldValue]
                oldSelectedItem.isSelected = false
                if self.itemFontChangeFollowContentScroll {
                    // 如果支持字体平滑渐变切换，则设置item的scale
                    let scale = self.itemTitleUnselectedFontScale
                    oldSelectedItem.transform = CGAffineTransform(scaleX: scale, y: scale)
                    oldSelectedItem.scaleTitleWidth = oldSelectedItem.titleWidth * scale
                } else {
                    // 如果支持字体平滑渐变切换，则直接设置字体
                    oldSelectedItem.titleFont = self.itemTitleFont
                }
            }
            
            let newSelectedItem = self.items[selectedItemIndex]
            newSelectedItem.isSelected = true
            if self.itemFontChangeFollowContentScroll {
                // 如果支持字体平滑渐变切换，则设置item的scale
                newSelectedItem.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                newSelectedItem.scaleTitleWidth = newSelectedItem.titleWidth
            } else {
                // 如果支持字体平滑渐变切换，则直接设置字体
                if let itemTitleSelectedFont = self.itemTitleSelectedFont {
                    newSelectedItem.titleFont = itemTitleSelectedFont
                }
            }
            
            if self.lineViewSwitchAnimated && oldValue >= 0 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.updateLineViewFrame(self.selectedItemIndex)
                })
            } else {
                self.updateLineViewFrame(selectedItemIndex)
            }
            
            self.delegate?.pageBar(bar: self, didSelectedItemAt: selectedItemIndex, isReload: false)
        }
    }
    
    var itemTitleColor: UIColor = UIColor.red {
        didSet {
            for item in items {
                item.titleColor = itemTitleColor
            }
        }
    }
    
    var itemTitleSelectedColor: UIColor = UIColor.lightGray {
        didSet {
            for item in items {
                item.titleSelectedColor = itemTitleSelectedColor
            }
        }
    }
    
    var itemTitleFont: UIFont = UIFont.systemFont(ofSize: 17.0) {
        didSet {
            if self.itemFontChangeFollowContentScroll {
                // item字体支持平滑切换，更新每个item的scale
                self.updateItemsScaleIfNeeded()
            } else {
                // item字体不支持平滑切换，更新item的字体
                if self.itemTitleSelectedFont != nil {
                    // 设置了选中字体，则只更新未选中的item
                    for item in self.items {
                        if !item.isSelected {
                            item.titleFont = itemTitleFont
                        }
                    }
                } else {
                    // 未设置选中字体，更新所有item
                    for item in self.items {
                        item.titleFont = itemTitleFont
                    }
                }
            }
        }
    }
    
    var itemTitleSelectedFont: UIFont? {
        didSet {
            self.selectedItem?.titleFont = itemTitleSelectedFont
            self.updateItemsScaleIfNeeded()
            
        }
    }
    
    var items: [LPPageItem] = [] {
        willSet {
            for item in items {
                item.removeFromSuperview()
            }
        }
        didSet {
            for item in items {
                item.titleColor = self.itemTitleColor
                item.titleSelectedColor = self.itemTitleSelectedColor
                item.titleFont = self.itemTitleFont
                item.addTarget(self, action: #selector(pageItemClicked), for: UIControl.Event.touchUpInside)
                
//                item.layer.borderWidth = 1.0
//                item.layer.borderColor = UIColor.blueColor().CGColor
                
                self.addSubview(item)
            }
            self.addSubview(self.lineView)
            print("add items lineView to superView")
            
            self.updateItemsFrame() // 更新每个item的位置
            self.updateItemsScaleIfNeeded() // 更新item的大小缩放
        }
    }
    
    var lineViewScrollFollowContent: Bool = true  // Item的选中背景是否随contentView滑动而移动
    var itemColorChangeFollowContentScroll: Bool = true // 拖动内容视图时，item的颜色是否根据拖动位置显示渐变效果，默认为true
    var itemFontChangeFollowContentScroll: Bool = true { // 拖动内容视图时，item的字体是否根据拖动位置显示渐变效果，默认为true
        didSet {
            self.updateItemsScaleIfNeeded()
        }
    }
    
    override var frame: CGRect {
        didSet {
            super.frame = frame
            
            self.updateItemsFrame() // 更新items的frame
            self.updateLineViewFrame(self.selectedItemIndex) // 更新选中背景的frame
        }
    }
    
    /// 获取未选中字体与选中字体大小的比例
    fileprivate var itemTitleUnselectedFontScale: CGFloat {
        get {
            if let itemTitleSelectedFont = itemTitleSelectedFont {
                return self.itemTitleFont.pointSize / itemTitleSelectedFont.pointSize
            }
            return 1.0
        }
    }
    
    // MARK: - Private
    
    fileprivate func updateItemsScaleIfNeeded() {
        if let itemTitleSelectedFont = self.itemTitleSelectedFont {
            if self.itemFontChangeFollowContentScroll && itemTitleSelectedFont.pointSize != self.itemTitleFont.pointSize {
                for item in self.items {
                    item.titleFont = itemTitleSelectedFont
                }
                for item in self.items {
                    if !item.isSelected {
                        let scale = self.itemTitleUnselectedFontScale
                        item.transform = CGAffineTransform(scaleX: scale, y: scale)
                        item.scaleTitleWidth = item.titleWidth * scale
                    }
                }
            }
        }
    }
    
    fileprivate func updateItemsFrame() {
        if self.items.count == 0 {
            return
        }
        var x: CGFloat = self.leftAndRightSpacing
        var itemWidth = (self.frame.width - self.leftAndRightSpacing * 2 - self.itemSpacing * CGFloat(self.items.count - 1)) / CGFloat(self.items.count)
        itemWidth = CGFloat(floorf(Float(itemWidth) + 0.5)) // 四舍五入，取整，防止字体模糊
        for (idx, item) in self.items.enumerated() {
            item.frame = CGRect(x: x, y: 0.0, width: itemWidth, height: self.frame.height)
            item.index = idx
            x += itemWidth + self.itemSpacing
            //print("idx=\(idx), item frame=\(item.frame)")
        }
    }
    
    /// 更新选中背景的frame
    fileprivate func updateLineViewFrame(_ index: Int) {
        if index < 0 || index >= self.items.count {
            return
        }
        let item = self.items[index]
        switch self.lineViewMode {
        case .resizesToTextWidth:
            self.lineView.frame = CGRect(x: 0.0,
                                         y: self.frame.height - self.lineViewHeight - self.lineViewBottomOffset,
                                         width: item.scaleTitleWidth + self.lineViewWidthWithSpacing * 2.0,
                                         height: self.lineViewHeight)
        case .fillItem:
            self.lineView.frame = CGRect(x: 0.0,
                                         y: self.frame.height - self.lineViewHeight - self.lineViewBottomOffset,
                                         width: item.frame.width + self.lineViewWidthWithSpacing * 2.0,
                                         height: self.lineViewHeight)
        case .fixedWidth:
            self.lineView.frame = CGRect(x: 0.0,
                                         y: self.frame.height - self.lineViewHeight - self.lineViewBottomOffset,
                                         width: self.lineViewWidthWithSpacing,
                                         height: self.lineViewHeight)
        }
        self.lineView.center.x = item.center.x
    }
    
    // MARK: - Public
    
    func setTitles(_ titles: [String]) {
        var items: [LPPageItem] = []
        for title in titles {
            let item = LPPageItem()
            item.title = title
            items.append(item)
        }
        self.items = items
    }
    
    @objc func pageItemClicked(_ item: LPPageItem) {
        if (self.selectedItemIndex == item.index) {
            self.delegate?.pageBar(bar: self, didSelectedItemAt: selectedItemIndex, isReload: true)
            return
        }
        if self.delegate?.pageBar(bar: self, willSelectItemAt: item.index) ?? true {
            self.selectedItemIndex = item.index
        }
    }
    
    deinit {
        print("LPPageBar -> release memory.")
    }
}

extension LPPageBar: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.selectedItemIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 如果不是手势拖动导致的此方法被调用，不处理
        if !(scrollView.isDragging || scrollView.isDecelerating) {
            return
        }
        
        // 滑动越界不处理
        let offsetX = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.frame.size.width
        if offsetX < 0 {
            return
        }
        if offsetX > scrollView.contentSize.width - scrollViewWidth {
            return
        }
        let leftIndex = Int(offsetX / scrollViewWidth)
        let rightIndex = Int(leftIndex + 1)
        
        var leftItemOptional: LPPageItem?
        var rightItemOptional: LPPageItem?
        if self.items.count > leftIndex && leftIndex >= 0 {
            leftItemOptional = self.items[leftIndex]
        }
        if self.items.count > rightIndex && rightIndex >= 0 {
            rightItemOptional = self.items[rightIndex]
        }
        
        guard let leftItem = leftItemOptional else {
            return
        }
        guard let rightItem = rightItemOptional else {
            return
        }
        
        // 计算右边按钮偏移量
        var rightScale = offsetX / scrollViewWidth
        // 只想要 0~1
        rightScale = rightScale - CGFloat(leftIndex)
        let leftScale = 1.0 - rightScale
        
        if self.itemFontChangeFollowContentScroll && self.itemTitleUnselectedFontScale != 1.0 {
            // 如果支持title大小跟随content的拖动进行变化，并且未选中字体和已选中字体的大小不一致
            // 计算字体大小的差值
            let diff = self.itemTitleUnselectedFontScale - 1.0
            // 根据偏移量和差值，计算缩放值
            leftItem.transform = CGAffineTransform(scaleX: rightScale * diff + 1.0, y: rightScale * diff + 1.0)
            rightItem.transform = CGAffineTransform(scaleX: leftScale * diff + 1.0, y: leftScale * diff + 1.0)
            
            leftItem.scaleTitleWidth = leftItem.titleWidth * (rightScale * diff + 1.0)
            rightItem.scaleTitleWidth = rightItem.titleWidth * (leftScale * diff + 1.0)
        }
        
        if self.itemColorChangeFollowContentScroll {
            var normalRed: CGFloat = 0.0, normalGreen: CGFloat = 0.0, normalBlue: CGFloat = 0.0
            var selectedRed: CGFloat = 0.0, selectedGreen: CGFloat = 0.0, selectedBlue: CGFloat = 0.0
            self.itemTitleColor.getRed(&normalRed, green: &normalGreen, blue: &normalBlue, alpha: nil)
            self.itemTitleSelectedColor.getRed(&selectedRed, green: &selectedGreen, blue: &selectedBlue, alpha: nil)
            
            // 获取选中和未选中状态的颜色差值
            let redDiff = selectedRed - normalRed
            let greenDiff = selectedGreen - normalGreen
            let blueDiff = selectedBlue - normalBlue
            // 根据颜色值的差值和偏移量，设置pageItem的标题颜色
            leftItem.titleLabel?.textColor = UIColor(red: leftScale * redDiff + normalRed,
                                                    green: leftScale * greenDiff + normalGreen,
                                                    blue: leftScale * blueDiff + normalBlue,
                                                    alpha: 1.0)
            rightItem.titleLabel?.textColor = UIColor(red: rightScale * redDiff + normalRed,
                                                      green: rightScale * greenDiff + normalGreen,
                                                      blue: rightScale * blueDiff + normalBlue,
                                                      alpha: 1.0)
        }
        
        // 计算背景的frame
        if self.lineViewScrollFollowContent {
            switch self.lineViewMode {
            case .resizesToTextWidth:
                let widthDiff = rightItem.scaleTitleWidth - leftItem.scaleTitleWidth
                if widthDiff != 0.0 {
                    self.lineView.frame.size.width = rightScale * widthDiff + leftItem.scaleTitleWidth + self.lineViewWidthWithSpacing * 2.0
                }
            case .fillItem:
                let widthDiff = rightItem.frame.width - leftItem.frame.width
                if widthDiff != 0.0 {
                    self.lineView.frame.size.width = rightScale * widthDiff + leftItem.frame.width + self.lineViewWidthWithSpacing * 2.0
                }
            case .fixedWidth:
                let widthDiff = rightItem.frame.width - leftItem.frame.width
                if widthDiff != 0.0 {
                    self.lineView.frame.size.width = self.lineViewWidthWithSpacing
                }
            }
            self.lineView.center.x = (rightItem.center.x - leftItem.center.x) * rightScale + leftItem.center.x
        }
    }
}
