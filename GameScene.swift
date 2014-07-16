//
//  GameScene.swift
//  phoneLadder
//
//  Created by 张宏台 on 14-6-28.
//  Copyright (c) 2014年 张宏台. All rights reserved.
//

import SpriteKit
import Foundation
import UIKit

class GameScene: SKScene,DiceGameDelegate {

    //记录游戏背景图片的中心位置，就是蛇和梯子的25格图
    var boardP:CGPoint = CGPointMake(0,0)
    //记录游戏背景图片的尺寸大小
    var boardSize:CGSize = CGSizeMake(0,0)

    //游戏背景图片元素
    var spriteBoard = SKSpriteNode()
    //飞船元素，在此Demo中以项目已经给的默认图片飞船为在方格上移动的玩家。
    var spriteShip = SKSpriteNode()

    struct PointProperty
    {
        var pointPosition:CGPoint = CGPointMake(0,0)
        var angle:CGFloat = 0.0
    }
    var pointsPosition:Dictionary<Int,PointProperty> = [:]
    
    var stepOn = 1
    var myLabel = SKLabelNode()
    //定义一个游戏实例
    let game = SnakesAndLadders()
    //记录掷色子的次数，即投掷了多少次色子获得胜利
    var numberOfTurns = 0

    override func didMoveToView(view: SKView) {
        println("present scane")
        /* Setup your scene here */
        ////设置背景颜色
        var skyColor = SKColor()
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        //添加背景图片，蛇和梯子的25格图
        var skyTexture = SKTexture(imageNamed: "board")
        //设置大小和位置
        spriteBoard = SKSpriteNode(texture:skyTexture)
        //它的位置是左右居中。Scene的Y轴是由下至上的，所以是屏幕高度除以2+150，即中间靠上的位置
        spriteBoard.position = CGPointMake(self.frame.size.width/2,spriteBoard.size.height/2+150)
        boardP = spriteBoard.position
        //在模拟器中我使用screen的大小为参考，否则很难控制这个图片的显示。
        var screen = UIScreen.mainScreen()
        println("screen width:\(screen.bounds.size.width),height:\(screen.bounds.size.height)")
        println("board width:\(spriteBoard.size.width),height:\(spriteBoard.size.height)")

        spriteBoard.setScale(screen.bounds.size.width/spriteBoard.size.width*1.3)
        boardSize = spriteBoard.size
        self.addChild(spriteBoard)
        
        //添加标签，上部文字说明
        myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "player one";
        myLabel.fontSize = 20;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:self.frame.size.height-100);
        
        self.addChild(myLabel)

        
        //用飞船代替玩家
        spriteShip = SKSpriteNode(imageNamed:"Spaceship")
        println("spaceShip width:\(spriteShip.size.width),height:\(spriteShip.size.height)")
        spriteShip.setScale(screen.bounds.size.width/boardSize.width*0.2)
        //它的初始位置是25格的最左最下的方格。计算方法是以25格图中心点为参考，向左移动两格，向下移动两格，即第一个方格。
        spriteShip.position = CGPointMake(boardP.x-boardSize.width/5*2,spriteBoard.position.y-boardSize.height/5*2)
        self.addChild(spriteShip)
        //给game添加游戏代理并开始游戏
        game.delegate = self
        game.start()
        //设置飞船在每一个点的位置和朝向
        var distanceX = boardSize.width/5
        var distanceY = boardSize.height / 5
        //以第一个点为参考坐标
        let originPos:CGPoint = spriteShip.position
        for i:Int in 0..25 {
            //cy是行数,Y轴方向
            var cy = i/5
            var mark:Int = 1
            //第0行是正向，第1行是反方向
            if(cy%2 != 0){
                mark = -1
            }
            //对着图看，X是从0加到4，又从4减到0，所以根据行数来决定是加还是减
            //	1	 	2		3		4		5		6		7		8		9		10 		...
            //(0,0)		(1,0)	(2,0)	(3,0)	(4,0)	(4,1)	(3,1)	(2,1)	(1,1)	(0,1)
            var cx = (i%5)*mark + ((i/5)%2)*4;
            //println("\(i):(\(cx),\(cy))")
            var px = originPos.x + CGFloat(cx) * distanceX
            var py = originPos.y + CGFloat(cy) * distanceY
            var pos = CGPointMake(px,py)
            //方向
            var angle:CGFloat = M_PI;
            if((i+1)%5 == 0){
                //第5，10,15,20,25格式朝上的，角度为90
                angle = M_PI / 2.0
            }
            else{
                if((i/5) % 2 == 0){
                    //第0,2,4行是朝右的，角度为0
                    angle = 0.0
                }else{
                    //第1,3行是朝左的，角度为180
                    angle = M_PI
                }
            }
            pointsPosition[i+1] = PointProperty(pointPosition: pos,angle: angle)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            if node === spriteBoard {
                game.play();
            }
        }
    }
    
    //直线前进，从start直接启动到step
    func straightMove(start:Int,end:Int) -> SKAction {
        var actionList:SKAction[] = []
        //取得移动的x,y长度，求出斜边的长度，通过反cos函数，求得角度（画图研究下吧，别说上学学的东西都用不到了，我是真费了半天的劲）
        var x = pointsPosition[end]!.pointPosition.x - pointsPosition[start]!.pointPosition.x
        
        var y = pointsPosition[end]!.pointPosition.y - pointsPosition[start]!.pointPosition.y
        var xy2 = x*x + y*y
        var distance:CGFloat = sqrt(xy2)
        var direction:CGFloat = 0.0
        if(y < 0){
            direction = (-acos(x/distance) + 2*M_PI)%(2*M_PI)
        }else{
            direction = (acos(x/distance) + 2*M_PI)%(2*M_PI)
            
        }
        
        //总是旋转比较小的角度
        func rotatePi(direct:CGFloat) -> CGFloat{
            if(direct > M_PI){
                return direct - 2 * M_PI
            }
            else if(direct < -M_PI){
                return direct+2*M_PI
            }
            else{
                return direct
            }
        }
        var rotateAngle1 = direction - pointsPosition[start]!.angle
        rotateAngle1 = rotatePi(rotateAngle1)
        var rotateAngle2 = pointsPosition[end]!.angle - direction
        rotateAngle2 = rotatePi(rotateAngle2)
        //下面就是动画序列，旋转-》移动-》旋转
        actionList += SKAction.rotateByAngle(rotateAngle1,duration:NSTimeInterval(0.2*fabs(rotateAngle1)))
        actionList += SKAction.moveByX(x,y:y,duration:NSTimeInterval(0.01*distance))
        actionList += SKAction.rotateByAngle(rotateAngle2,duration:NSTimeInterval(0.2*fabs(rotateAngle2)))
        //本函数仅生成动画序列，然后返回
        return SKAction.sequence(actionList)
    }
    
    func diceStepForward(start: Int,step: Int) -> SKAction
        
    {
        var end = start+step
        println("step from \(start) to \(end)")
        var actionList:SKAction[] = []
        
        for i in start..end {
            
            actionList += straightMove(i,end: i+1)
            
        }
        
        var moveActionArray = SKAction.sequence(actionList)
        
        return moveActionArray
        
    }
    
    
    

    func gameDidStart(game:DiceGame) {
        numberOfTurns = 0
        if game is SnakesAndLadders{
            myLabel.text = "Game Is Going"
            let ourGame = game as SnakesAndLadders
            //假如是游戏进行到一半，重新开始，则飞机从当前移动到起点
            if ourGame.square != 1 {
                var actions:SKAction[] = []
                actions += straightMove(ourGame.square,end:1)
                println("strait go from \(ourGame.square) to 1")
                spriteShip.runAction(SKAction.sequence(actions))
            }
            
        }
    }
    //代理的作用是可以直接使用GameScene的元素，比如myLabel,最简单的体现
    func gameDidEnd(game:DiceGame){
        myLabel.text = "You Win Game for \(numberOfTurns) turns"
        
    }
    //掷色子后的飞船移动
    func gamePlay(diceGame:DiceGame,didStartNewTurnWithDiceRoll diceRoll:Int) -> Int {
        myLabel.text = "You Rolled \(diceRoll)"
        let game = diceGame as SnakesAndLadders
        ++numberOfTurns
        println("you rolled \(numberOfTurns) times,this time rolled \(diceRoll)")
        var steps:Int = 0
        var currentSquare = game.square
        var actions:SKAction[] = []
        //这是对游戏的一个小改善，如果没有正好到达25格，则后退，直到正好抵达25格算是游戏结束
        if(currentSquare + diceRoll > game.finalSquare){
            steps = game.finalSquare - currentSquare
            actions += diceStepForward(currentSquare,step:steps)
            currentSquare += steps
            var backs = diceRoll - steps
            actions += straightMove(currentSquare,end:currentSquare-backs)
            println("strait go from \(currentSquare) to \(currentSquare-backs)")
            
            steps = steps - backs
            currentSquare -= backs
        }else{
            actions += diceStepForward(currentSquare,step:diceRoll)
            steps = diceRoll
            currentSquare += steps
        }
        //这是遇到蛇或者梯子了，直接后退或者前进
        if(game.board[currentSquare] != 0){
            actions += straightMove(currentSquare,end:(currentSquare+game.board[currentSquare]))
            println("strait go from \(currentSquare) to \(currentSquare+game.board[currentSquare])")
            steps += game.board[currentSquare]
        }
        //调用飞船的runAction，执行动画播放
        spriteShip.runAction(SKAction.sequence(actions))
        return steps
    }
    func gameRestartAsk() -> UIAlertController{
        let title = NSLocalizedString("Quit Ask", comment: "")
        let message = NSLocalizedString("Do you want quit the current game and restart.", comment: "")
        let cancelButtonTitle = NSLocalizedString("Nope", comment: "")
        let otherButtonTitle = NSLocalizedString("Yeah", comment: "")
        
        let alertCotroller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            println("The game is going on.")
        }
        
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { action in
            self.game.start()
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        return alertCotroller
        //return false
    }
    func gameAlert(){
        let tit = NSLocalizedString("提示", comment: "")
        let msg = NSLocalizedString("游戏已结束，是否重新开始？", comment: "")
        var alert:UIAlertView = UIAlertView()
        alert.title = tit
        alert.message = msg
        alert.delegate = self
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        alert.show()
    }
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex == 0){
            self.game.start()
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
