//
//  ViewController.swift
//  GPPageView
//
//  Created by cocoaziyue on 2019/2/28.
//  Copyright © 2019年 cocoaziyue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var table1: UITableView = {
        let table1 = UITableView()
        return table1
    }()
    
    lazy var table2: UITableView = {
        let table2 = UITableView()
        return table2
    }()
    
    lazy var table3: UITableView = {
        let table3 = UITableView()
        return table3
    }()
    
    lazy var table4: UITableView = {
        let table4 = UITableView()
        return table4
    }()
    
    lazy var headerView: UIView = {
        let tmpView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
        tmpView.backgroundColor = UIColor.red
        return tmpView
    }()
    
    lazy var segmentItem: LPPageBar = {
        let tmpSeg = LPPageBar.init(frame: CGRect.init(x: 0, y: 200, width: UIScreen.main.bounds.width, height: 44))
        tmpSeg.backgroundColor = UIColor.yellow
        return tmpSeg
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
      
        //加入header
        view.addSubview(headerView)
        
        //加入segment
        view.addSubview(segmentItem)
        let titles = ["第一个","第二个","第三个","第四个"]
        segmentItem.selectedItemIndex = 0
        segmentItem.setTitles(titles)
        
        //加入vc
        let pageVC = BasePageViewController.init(headView: headerView, hoverView: segmentItem, subViewCount:4)        //1
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.configTableView(subViews: [table1,table2,table3,table4], selectIndex: 0)

        //置前
        self.view.bringSubviewToFront(headerView)
        self.view.bringSubviewToFront(segmentItem)
    }

}

