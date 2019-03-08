//
//  RootViewController.swift
//  GPPageView
//
//  Created by cocoaziyue on 2019/3/5.
//  Copyright © 2019年 cocoaziyue. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "界面"
        // a
        let vc = ViewController()
        addChild(vc)
        
        view.addSubview(vc.view)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
