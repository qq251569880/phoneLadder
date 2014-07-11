//
//  ViewController.swift
//  phoneLadder
//
//  Created by 张宏台 on 14-7-10.
//  Copyright (c) 2014年 张宏台. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class ViewController: UIViewController {
    var skView: SKView = SKView()
    
    //询问按钮
    var scene:GameScene!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.scene = GameScene()
        self.scene.scaleMode = .AspectFill
        self.skView.showsDrawCount = true
        self.skView.showsFPS = true
        self.skView.presentScene(self.scene)
        //btn.frame = CGRect(x: CGRectGetMidX(self.frame), y: 10,width: 200,height: 100);
        btn.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)
        UIView.animateWithDuration(2.0) {
            self.btn.alpha = 1.0
        }
    }
}