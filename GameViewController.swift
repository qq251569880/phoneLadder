//
//  GameViewController.swift
//  phoneLadder
//
//  Created by 张宏台 on 14-6-28.
//  Copyright (c) 2014年 张宏台. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        
        var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
        archiver.finishDecoding()
        return scene
    }
}

class GameViewController: UIViewController {
    var btn:UIButton = UIButton()
    var gameScene:GameScene?
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill

            skView.presentScene(scene)
            
            var screen = UIScreen.mainScreen()
            println("screen width:\(screen.bounds.size.width),height:\(screen.bounds.size.height)")
            
            let buttonTitle = NSLocalizedString("RESTART", comment: "you will restart the game")
            btn.setTitle(buttonTitle,forState: .Normal)
            
            var image = UIImage(named:"button")
            btn.setBackgroundImage(image,forState: .Normal)
            
            btn.frame = CGRect(x:screen.bounds.size.width/2-50, y:screen.bounds.size.height-100,width:100,height:50)
            
            btn.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)
            skView.addSubview(btn)
            gameScene = scene
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    func buttonClicked(sender: UIButton) {
        print("A button was clicked: \(sender).")
        if let scene = gameScene? {
            println("board width:\(scene.spriteBoard.size.width),height:\(scene.spriteBoard.size.height)")
            var alert = scene.gameRestartAsk()
            presentViewController(alert, animated: true, completion: nil)

        }
    }

}
