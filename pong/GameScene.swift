//
//  GameScene.swift
//  pong
//
//  Created by SUP'Internet 08 on 08/03/2018.
//  Copyright © 2018 SUP'Internet 08. All rights reserved.
//

import SpriteKit
import GameplayKit





/*
protocol Alertable { }
extension Alertable where Self: SKScene {
    
    func resetGame() {
        self.scene?.view?.isPaused = false
        //TODO remove every particles node here
    }
    
    
    func showAlert(withTitle title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Recommencer", style: .cancel) { _ in self.resetGame() }
        alertController.addAction(okAction)
        
        view?.window?.rootViewController?.present(alertController, animated: true)
        
        
    }
    
    func showAlertWithSettings(withTitle title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Recommencer", style: .cancel) { _ in }
        alertController.addAction(okAction)
        

        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            
            guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        alertController.addAction(settingsAction)
        
        view?.window?.rootViewController?.present(alertController, animated: true)
    }
}
 */





class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String:GKGraph]()
    
    
    
    var player_bottom_scored = 0
    var player_top_scored = 0
    
    var elements = [String: SKSpriteNode]() //get all elements in view (entities)
    
    
    var elementsLabel = [String: SKLabelNode]()
    

    
    
    
    var level: String = ""
    var IAAnimationDuration: Double = 0.0
    
    
    var controller: UIViewController?
    
    
    
    func resetGame() {
        self.scene?.childNode(withName: "ki1")?.position = CGPoint(x: self.frame.midX, y: (self.frame.maxY - 250))
        self.scene?.childNode(withName: "ki2")?.position = CGPoint(x: self.frame.midX, y: (self.frame.minY + 250))

        //self.scene?.view?.isPaused = false
        //TODO remove every particles node here
        
    }
    
    
    
    //particle loading + event
    func newSmokeEmitter() -> SKEmitterNode? {
        return SKEmitterNode(fileNamed: "BallExplosion.sks")
    }
    
    func newExplosionParticleNode(scene: SKScene, positionEffect: String, ballPosX: CGFloat) {
        guard let emitter = SKEmitterNode(fileNamed: "BallExplosion.sks") else {
            return
        }
        
        
        
        if(positionEffect == "bottom"){
            emitter.position = CGPoint(x: ballPosX + 10, y: (self.frame.minY) - 10 )
        }else if(positionEffect == "top"){
            emitter.position = CGPoint(x: ballPosX + 10, y: (self.frame.maxY) + 10 )
        }
        

        
        let scaleSequence = SKKeyframeSequence(keyframeValues: [0.2, 0.7, 0.1],
                                               times: [0.0, 0.250, 0.4])
        emitter.particleScaleSequence = scaleSequence
        
        //Lifetime of animation, remove by let waitAction
        emitter.particleLifetime = CGFloat(0.5)
        
        // Place the emitter at the rear of the ship.
        emitter.name = "BallExplosion"
        // Send the particles to the scene.
        emitter.targetNode = scene;
        scene.addChild(emitter)
        
        let waitAction = SKAction.wait(forDuration: TimeInterval(emitter.particleLifetime))
        emitter.run(waitAction, completion: {
            emitter.removeFromParent()
        })
    }
    
    
    
    
    //Explosion end
    func endExplode(scene: SKScene) {
        guard let emitter = SKEmitterNode(fileNamed: "MyParticle.sks") else {
            return
        }
        
        
        emitter.position = CGPoint(x:self.frame.midX, y: self.frame.midY)
        
        let scaleSequence = SKKeyframeSequence(keyframeValues: [0.6, 1, 0.6],
                                               times: [0.0, 1, 0.4])
        emitter.particleScaleSequence = scaleSequence
        
        //Lifetime of animation, remove by let waitAction
        emitter.particleLifetime = CGFloat(0.8)
        
        // Place the emitter at the rear of the ship.
        emitter.name = "MyParticle"
        // Send the particles to the scene.
        emitter.targetNode = scene;
        scene.addChild(emitter)
        
        let waitAction = SKAction.wait(forDuration: TimeInterval(emitter.particleLifetime))
        emitter.run(waitAction, completion: {
            emitter.removeFromParent()
        })
    }

    
    
    //generate random value for ball position
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    

    
    override func didMove(to view: SKView) { //when element arrived on view GamScene
        
        // LEVEL OPTION
        if(self.level == "BoutonMedium"){
            IAAnimationDuration = 0.3
        }
        if(self.level == "BoutonEasy"){
            IAAnimationDuration = 0.5
        }
        
        if(self.level == "BoutonHard"){
            IAAnimationDuration = 0.1
        }
        
        
        print(self.level)
        print(IAAnimationDuration)
        
        
        
        elements["ball"] = self.childNode(withName: "ball") as! SKSpriteNode
        elements["player_bottom"] = self.childNode(withName: "player_bottom") as! SKSpriteNode?
        elements["player_top"] = self.childNode(withName: "player_top") as! SKSpriteNode?
        
        
        
        //display result 
        elementsLabel["display_score_top"] = self.childNode(withName: "display_score_top") as! SKLabelNode
        elementsLabel["display_score_bottom"] = self.childNode(withName: "display_score_bottom") as! SKLabelNode
        
        

        //Shuriken
        
        let shurikenTexture = SKTexture(imageNamed: "shuriken.png")

        
        let shuriken1 = SKSpriteNode(texture: shurikenTexture)
        shuriken1.position = CGPoint(x: (self.frame.maxX - 150), y: (self.frame.maxY) - 550)
        shuriken1.physicsBody = SKPhysicsBody(texture: shurikenTexture,
                                              size: CGSize(width: shurikenTexture.size().width,
                                                           height: shurikenTexture.size().height))
        shuriken1.name = "shuriken1"
        shuriken1.physicsBody?.pinned = true
        shuriken1.physicsBody?.friction = 0

        
        let shuriken2 = SKSpriteNode(texture: shurikenTexture)
        shuriken2.position = CGPoint(x: (self.frame.minX + 150), y: (self.frame.minY) + 550)
        shuriken2.physicsBody = SKPhysicsBody(texture: shurikenTexture,
                                                      size: CGSize(width: shurikenTexture.size().width,
                                                                   height: shurikenTexture.size().height))
        shuriken2.name = "shuriken1"

        shuriken2.physicsBody?.pinned = true
        shuriken1.physicsBody?.friction = 0



        self.addChild(shuriken1)
        self.addChild(shuriken2)

        let oneRevolution:SKAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 2)
        let repeatRotation:SKAction = SKAction.repeatForever(oneRevolution)
        

        
        shuriken1.run(oneRevolution)
        shuriken2.run(oneRevolution)
        
        
        
            //ki
            let kiTexture = SKTexture(imageNamed: "ki.png")
            let kiTexture_red = SKTexture(imageNamed: "ki_red.png")
            
            let ki_ball_1 = SKSpriteNode(texture: kiTexture_red)
            ki_ball_1.position = CGPoint(x: self.frame.midX, y: (self.frame.maxY - 250))
            ki_ball_1.physicsBody?.pinned = true
            ki_ball_1.physicsBody?.friction = 0
            ki_ball_1.size.width = 130
            ki_ball_1.size.height = 80
            ki_ball_1.name = "ki1"
            
            
            
            let ki_ball_2 = SKSpriteNode(texture: kiTexture)
            ki_ball_2.position = CGPoint(x: self.frame.midX, y: (self.frame.minY + 250))
            ki_ball_2.physicsBody?.pinned = true
            ki_ball_2.physicsBody?.friction = 0
            ki_ball_2.size.width = 60
            ki_ball_2.size.height = 60
            ki_ball_2.name = "ki2"
            
            
            
            self.addChild(ki_ball_1)
            self.addChild(ki_ball_2)
        
        
    
            ki_ball_1.run(repeatRotation)
            ki_ball_2.run(repeatRotation)


        
       



        



        
        /*
 
         //todo GENERATE A random X and Y for ball impusle
         
         let xBallImpulse = self.generateRandomNumber(min: -10, max: 10)
         let yBallImpulse = self.generateRandomNumber(min: -30, max: 30)
         
         puis mettre ca dans CGVector dx et dy 
         
         
         QUAND le score sera à 10 reset avec une modal qui prend le nom de l'user gagnat et reset le counter de points à 0
         rajouter un if dans le update sur count à 10
         
        */

        //physicBody (get all physic of element target
        //Speed random for ball
        /*
        var dxBall = randomFloat(min: -31, max: -60)
        var dyBall = randomFloat(min: -31, max: -60)
        */
        
        //elements["ball"]?.physicsBody?.applyImpulse( CGVector(dx: Int(dxBall), dy: Int(dyBall) )) //when its start, its the move speed
        
        
        elements["ball"]?.physicsBody?.velocity = CGVector(dx: 0, dy: 0) //set ball in middle without movement (click to start)

    
        let frameBody = SKPhysicsBody(edgeLoopFrom: self.frame) //definit une box qui sera le cadre du jeu (on enferme le jeu dans une box)
        
        //definit les parametre du cadre du jeu et on l'enregistre
        frameBody.friction = 0 //la friction fait ralentit quand ca tape
        frameBody.restitution = 1
        self.physicsBody = frameBody
        

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touched")
        
        //si un point a été marqué, touché l'écran reset la balle
        if( elements["ball"]?.physicsBody?.velocity == CGVector(dx: 0, dy: 0) ){
            var dxBall = randomFloat(min: -31, max: -60)
            var dyBall = randomFloat(min: -31, max: -60)
            elements["ball"]?.physicsBody?.applyImpulse( CGVector(dx: Int(dxBall), dy: Int(dyBall) ))
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            print("X : \(location.x)")
            print("Y : \(location.y)")
            
            if(location.y < 0){
                let moveNodeUpBottom = SKAction.moveTo(x: location.x, duration: 0.3)
                elements["player_bottom"]?.run(moveNodeUpBottom,
                                               withKey: "player_bottom")
                
                }
            }
        
        
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
        
        
        
        
        var ballPositionY = (elements["ball"]?.position.y)!
        var ballPositionX = (elements["ball"]?.position.x)!
      
        
        //follow the ball position with delay IA
        elements["player_top"]?.run(SKAction.moveTo(x: (elements["ball"]?.position.x)!, duration: IAAnimationDuration))
        // TODO : set medium / hardmod (change only duration 0.3 O.1)
        
        
        //check ball speed and reimpulse if necessary
        print(elements["ball"]?.physicsBody?.velocity.dx)
        print(elements["ball"]?.physicsBody?.velocity.dy)
        
        
        if(ballPositionY > (self.frame.maxY - 60) ){
            print("reset ball + set 1 point to bottom player")
            
            
            let ballPlayerBottom = self.childNode(withName: "ki2") as! SKSpriteNode //cast in SKSpriteNode to get .size. ...
            ballPlayerBottom.size.width += 35
            ballPlayerBottom.size.height += 30
            

            elements["ball"]?.position = CGPoint(x: 0, y: 0)

            //set velocity 0 to stop the ball and waiting user touchBegan to reset the impulse
            elements["ball"]?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

            self.newExplosionParticleNode(scene: self, positionEffect: "top", ballPosX: ballPositionX )
            
            //reset platform position

            self.player_bottom_scored += 1
            elementsLabel["display_score_bottom"]?.text = String(self.player_bottom_scored)
            
        }
        
        if(ballPositionY < (self.frame.minY + 60) ){
            print("reset ball + set 1 point to top player")
            
            let ballPlayerTop = self.childNode(withName: "ki1") as! SKSpriteNode //cast in SKSpriteNode to get .size. ...
            ballPlayerTop.size.width += 35
            ballPlayerTop.size.height += 30
            /*
            (ballPlayerTop?.frame.size.width)! + 600
            self.addChild(ballPlayerTop!)
            */
            
            
            
            elements["ball"]?.position = CGPoint(x: 0, y: 0)
            
            //set velocity 0 to stop the ball and waiting user touchBegan to reset the impulse
            elements["ball"]?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
           
            
            self.newExplosionParticleNode(scene: self, positionEffect: "bottom", ballPosX: ballPositionX )
            
            
            //reset platform position
          

            self.player_top_scored += 1
            elementsLabel["display_score_top"]?.text = String(self.player_top_scored)


        }
        
        //Resultat in real time 
        if(self.player_top_scored > self.player_bottom_scored){
            print("player TOP en tête, pts : \(self.player_top_scored)")
            
        }
        if(self.player_top_scored < self.player_bottom_scored){
            print("player BOTTOM en tête , pts : \(self.player_bottom_scored)")
        }
        if(self.player_top_scored == self.player_bottom_scored){
            print("Excéco, pts \(self.player_top_scored)")
        }
        
        //End of game (max 10pts)@
        if(self.player_top_scored >= 10){
            
            //self.scene?.view?.isPaused = true
            let winner = "PlayerTop"

            
            let alert = UIAlertController(title: "Winner", message: "\(winner)", preferredStyle: UIAlertControllerStyle.alert)
            let restartGameAction = UIAlertAction(title: "Recommencer", style: .cancel) { _ in self.resetGame() }
            alert.addAction(restartGameAction)
            self.controller?.present(alert, animated: true, completion: nil)
            
            //showAlert(withTitle: "Winner", message: "\(winner)")
           
            elementsLabel["display_score_top"]?.text = " 0 "
            elementsLabel["display_score_bottom"]?.text = " 0 "
            self.player_bottom_scored = 0
            self.player_top_scored = 0
            
            let ballPlayerBottom = self.childNode(withName: "ki2") as! SKSpriteNode //cast in SKSpriteNode to get .size. ...
            let ballPlayerTop = self.childNode(withName: "ki1") as! SKSpriteNode //cast in SKSpriteNode to get .size. ...
            
            ballPlayerTop.size = CGSize(width: 80, height: 130)
            print(ballPlayerTop.size)
            ballPlayerBottom.size = CGSize(width: 60, height: 60)
            
            let moveNodeUpBottom = SKAction.moveTo(y: self.frame.midY - 700, duration: 0.6)
            ballPlayerTop.run(moveNodeUpBottom,
                              withKey: "ki1")
            
            ballPlayerTop.run(moveNodeUpBottom, completion: {
                () -> Void in
                self.endExplode(scene: self)
                
                }
            )
            
            //self.endExplode(scene: self)
            
            

        }
        if(self.player_bottom_scored >= 10){
            //self.scene?.view?.isPaused = true
            let winner = "PlayerBottom"
            
            
            let alert = UIAlertController(title: "Winner", message: "\(winner)", preferredStyle: UIAlertControllerStyle.alert)
            let restartGameAction = UIAlertAction(title: "Recommencer", style: .cancel) { _ in self.resetGame() }
            alert.addAction(restartGameAction)
            self.controller?.present(alert, animated: true, completion: nil)
            
            //showAlert(withTitle: "Winner", message: "\(winner)")
            
            elementsLabel["display_score_top"]?.text = " 0 "
            elementsLabel["display_score_bottom"]?.text = " 0 "
            self.player_bottom_scored = 0
            self.player_top_scored = 0
            
            let ballPlayerBottom = self.childNode(withName: "ki2") as! SKSpriteNode //cast in SKSpriteNode to get .size. ...
            let ballPlayerTop = self.childNode(withName: "ki1") as! SKSpriteNode //cast in SKSpriteNode to get .size. ...

            ballPlayerTop.size = CGSize(width: 80, height: 130)
            ballPlayerBottom.size = CGSize(width: 60, height: 60)
            
            let moveNodeUpBottom = SKAction.moveTo(y: self.frame.midY + 800, duration: 0.6)
            ballPlayerBottom.run(moveNodeUpBottom,
                                           withKey: "ki2")
            
            self.endExplode(scene: self)
            

        }
        
        
        
        
       
    }
}
