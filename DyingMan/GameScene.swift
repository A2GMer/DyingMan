//
//  GameScene.swift
//  DyingMan
//
//  Created by 田中大翔 on 2023/03/20.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var scoreLabel: SKLabelNode!
        private var score = 0 {
            didSet {
                scoreLabel.text = "Score: \(score)"
            }
        }
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var enemySpawnInterval: TimeInterval = 2.0
        private var enemyMoveSpeed: TimeInterval = 4.0
        private var stage = 1
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        physicsWorld.contactDelegate = self
        // プレイヤーの追加
        spawnPlayer()
        // 敵の追加
        let spawnEnemyAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        let waitAction = SKAction.wait(forDuration: enemySpawnInterval)
        run(SKAction.repeatForever(SKAction.sequence([spawnEnemyAction, waitAction])))
        
        setupScoreLabel()
    }
    
    private func spawnPlayer() {
        let player = Player()
        player.position = CGPoint(x: self.size.width / 2, y: player.size.height / 2 + 20)
        addChild(player)
    }
    
    private func spawnEnemy() {
        let enemy = Enemy()
            let randomX = CGFloat(arc4random_uniform(UInt32(self.size.width - enemy.size.width))) + enemy.size.width / 2
            enemy.position = CGPoint(x: randomX, y: self.size.height + enemy.size.height / 2)
            addChild(enemy)

            let moveAction = SKAction.moveTo(y: -enemy.size.height, duration: enemyMoveSpeed)
            let removeAction = SKAction.removeFromParent()
            enemy.run(SKAction.sequence([moveAction, removeAction]))
        }
    
    private func setupScoreLabel() {
            scoreLabel = SKLabelNode(fontNamed: "Arial")
            scoreLabel.fontSize = 24
            scoreLabel.position = CGPoint(x: 20, y: self.size.height - 40)
            scoreLabel.horizontalAlignmentMode = .left
            scoreLabel.zPosition = 100
            scoreLabel.text = "Score: \(score)"
            addChild(scoreLabel)
        }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        
        for touch in touches {
                    let location = touch.location(in: self)
                    let nodes = self.nodes(at: location)
                    
                    for node in nodes {
                        if node.name == "restartButton" {
                            restartGame()
                            break
                        }
                    }
                }
    }
    
    private func restartGame() {
            let newScene = GameScene(size: self.size)
            let transition = SKTransition.crossFade(withDuration: 0.5)
            self.view?.presentScene(newScene, transition: transition)
        }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if score >= stage * 100 {
                    stage += 1
                    enemySpawnInterval *= 0.9
                    enemyMoveSpeed *= 0.9
                }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
            let firstBody: SKPhysicsBody
            let secondBody: SKPhysicsBody
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if let firstNode = firstBody.node, let secondNode = secondBody.node {
                if firstNode.name == "playerBullet" && secondNode.name == "enemy" {
                    firstNode.removeFromParent()
                    secondNode.removeFromParent()
                    // スコアを更新
                } else if firstNode.name == "player" && secondNode.name == "enemyBullet" {
                    firstNode.removeFromParent()
                    secondNode.removeFromParent()
                }
                // ゲームオーバー処理
                if firstNode.name == "player" && secondNode.name == "enemyBullet" {
                            firstNode.removeFromParent()
                            secondNode.removeFromParent()
                            // ゲームオーバー処理
                            gameOver()
                        }
                
                if firstNode.name == "playerBullet" && secondNode.name == "enemy" {
                            firstNode.removeFromParent()
                            secondNode.removeFromParent()
                            // スコアを更新
                            score += 10
                }
            }
        }
    private func gameOver() {
            // ゲームオーバーラベルを表示
            let gameOverLabel = SKLabelNode(fontNamed: "Arial")
            gameOverLabel.fontSize = 48
            gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            gameOverLabel.zPosition = 100
            gameOverLabel.text = "Game Over"
            addChild(gameOverLabel)
            
            // リスタートボタンを表示
            let restartButton = SKLabelNode(fontNamed: "Arial")
            restartButton.fontSize = 24
            restartButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 40)
            restartButton.zPosition = 100
            restartButton.name = "restartButton"
            restartButton.text = "Tap to Restart"
            addChild(restartButton)
        }
}
