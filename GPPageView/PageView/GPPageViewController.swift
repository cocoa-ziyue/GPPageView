//
//  BasePageViewController.swift
//  PageViewDemo
//
//  Created by cocoaziyue on 2019/2/28.
//  Copyright © 2019年 cocoaziyue. All rights reserved.
//

import UIKit
import MJRefresh

class GPPageViewController: UIViewController,UITableViewDelegate,UIScrollViewDelegate,LPPageBarDelegate {
    
    var hoverHeight: CGFloat = 0        //滑动到悬停的距离
    var tableConsetHeight: CGFloat = 0       //tableview下拉的距离
    var headView: UIView       //外界传入的可推动的HeaderView
    var hoverView: LPPageBar       //外界传入的悬停的View
    var subViewCount: UInt = 0   //列表视图个数
    var tableArray: [UITableView] = []
    var visibleTableArray: [UITableView] = []
    var currentIndex: Int = 0
    var needHeaderPan: Bool = true      //是否需要添加头部滑动
    
    lazy var mainScrollView: UIScrollView = {
        let tempScrollView = UIScrollView.init(frame: self.view.bounds)
        return tempScrollView
    }()
    
    lazy var mjHeader: MJRefreshNormalHeader = {
        let mjHeader = MJRefreshNormalHeader.init()
        mjHeader.refreshingBlock = {
            
        }
        return mjHeader
    }()
    
    lazy var panGes: UIPanGestureRecognizer = {
        let panGes = UIPanGestureRecognizer.init(target: self, action: #selector(panHeaderAction(pan:)))
        return panGes
    }()
    
    deinit {
        
    }
    
    required init(headView: UIView,hoverView: LPPageBar,subViewCount: UInt) {
        self.headView = headView
        self.hoverView = hoverView
        self.hoverHeight = headView.frame.height
        self.tableConsetHeight = headView.frame.height+hoverView.frame.height
        self.subViewCount = subViewCount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        view.addSubview(mainScrollView)
        mainScrollView.contentSize = CGSize.init(width: UIScreen.main.bounds.size.width * CGFloat(subViewCount), height: 0)
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.isPagingEnabled = true
        mainScrollView.bounces = false
        mainScrollView.delegate = self
        
        hoverView.delegate = self
        
        if #available(iOS 11.0, *) {
            self.mainScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needHeaderPan {
            headView.isUserInteractionEnabled = true
            headView.addGestureRecognizer(panGes)       //添加手势
        } else {
            headView.removeGestureRecognizer(panGes)        //移除手势
        }
    }
    
    func configTableView(subViews: [UITableView], selectIndex: Int) {
        self.tableArray = subViews
        self.currentIndex = selectIndex
        self.hoverView.selectedItemIndex = selectIndex
        setTableViewDetail(view: subViews[selectIndex])
        visibleTableArray.append(subViews[selectIndex])
    }
    
    func setRefreshHeader() {
        
    }
    
    @objc private func panHeaderAction(pan: UIPanGestureRecognizer) {
        
    }
    
    private func setTableViewDetail(view: UITableView) {
        visibleTableArray.append(view)
        self.mainScrollView.addSubview(view)
        view.delegate = self
        if GPPageConsetManager.shared.lastConsetY == 0 {
            GPPageConsetManager.shared.lastConsetY = -tableConsetHeight
        }
        view.frame = CGRect.init(x: mainScrollView.frame.width * CGFloat(currentIndex), y: 0, width: mainScrollView.frame.width, height: mainScrollView.frame.height)
        view.contentInset = UIEdgeInsets.init(top: tableConsetHeight, left: 0, bottom: 44+UIApplication.shared.statusBarFrame.height, right: 0)
        view.setContentOffset(CGPoint.init(x: 0, y: GPPageConsetManager.shared.lastConsetY), animated: false)        
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableArray[currentIndex] {
            let consetY = scrollView.contentOffset.y
            let headerConsetY = -(tableConsetHeight+consetY)
            headView.frame.origin.y = headerConsetY
            hoverView.frame.origin.y = hoverHeight+headerConsetY
            
            if hoverView.frame.origin.y <= 0.0 {
                hoverView.frame.origin.y = 0.0
            }
            
            //记录上次ConsetY
            GPPageConsetManager.shared.lastConsetY = consetY
            
            for item in self.visibleTableArray {
                if item != scrollView {
                    //其他tabelView的上滑不能超过hoverView(悬浮视图)的下方
                    if consetY > -hoverView.frame.height {
                        
                    } else {
                        item.setContentOffset(CGPoint.init(x: 0, y: consetY),animated: false)
                    }
                }
            }
        }
    }
    
    // MARK:scrollViewDelegate
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if mainScrollView == scrollView {
            let consetX = scrollView.contentOffset.x
            let currentIndex: Int = Int(consetX / UIScreen.main.bounds.width)
            hoverView.selectedItemIndex = currentIndex
            self.currentIndex = currentIndex
            
            guard currentIndex < tableArray.count else {
                return
            }
            
            let tableView = tableArray[currentIndex]
            if tableView.superview == nil {
                setTableViewDetail(view: tableView)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if mainScrollView == scrollView {
            self.scrollViewDidEndScrollingAnimation(scrollView)
        }
    }
    
    func pageBar(bar: LPPageBar, willSelectItemAt index: Int) -> Bool {
        return true
    }
    
    func pageBar(bar: LPPageBar, didSelectedItemAt index: Int, isReload: Bool) {
        mainScrollView.setContentOffset(CGPoint.init(x: UIScreen.main.bounds.width * CGFloat(index), y: 0), animated: true)
    }
    
}
