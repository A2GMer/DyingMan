//
//  GameScene.swift
//  DyingMan
//
//  Created by 田中大翔 on 2023/03/20.
//

import SpriteKit
import GameplayKit

enum GameState {
    case playing
    case gameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameCamera: SKCameraNode!
    
    let maxEnemies = 10
    var enemies = [Enemy]()
    
    var backgroundTiles: [SKSpriteNode] = []
    let backgroundTileHeight: CGFloat = 2000.0
    
    private var baseNode: SKSpriteNode!
    private var stickNode: SKSpriteNode!
    private var touch: UITouch?
    private var isMoving: Bool = false
    private var lastUpdateTime: TimeInterval = 0
    
    // 弾丸の移動速度
    private let bulletMoveSpeed: TimeInterval = 1.0
    private let enemyBulletSpawnInterval: TimeInterval = 1.0
    private var enemySpeed: CGFloat = 5.0
    
    
    private var gameState: GameState = .playing
    private var player = Player()
    private let playerParent = SKNode()
    
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
        
        gameCamera = SKCameraNode()
        addChild(gameCamera)
        camera = gameCamera
        
        let background = SKSpriteNode(imageNamed: "Sky")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size // 画面のサイズに背景画像を合わせる
        addChild(background)
        
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
        
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(playerParent)
        playerParent.addChild(player)
        
        // 敵の追加
        let spawnEnemyAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        let waitAction = SKAction.wait(forDuration: enemySpawnInterval)
        run(SKAction.repeatForever(SKAction.sequence([spawnEnemyAction, waitAction])))
        
        setupScoreLabel()
        
        // ジョイスティックのベースを作成
        baseNode = SKSpriteNode(color: .gray, size: CGSize(width: 100, height: 100))
        baseNode.alpha = 0.4
        baseNode.position = CGPoint(x: 120, y: 120)
        addChild(baseNode)
        
        // ジョイスティックのスティックを作成
        stickNode = SKSpriteNode(color: .white, size: CGSize(width: 50, height: 50))
        stickNode.alpha = 0.4
        stickNode.position = baseNode.position
        addChild(stickNode)
        
        // 定期的な弾の発射
        let bulletSpawnAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.spawnBullet(from: self.player, isEnemy: false, at: self.player.position)
        }
        let bulletWaitAction = SKAction.wait(forDuration: 0.5) // 0.5秒ごとに発射
        run(SKAction.repeatForever(SKAction.sequence([bulletSpawnAction, bulletWaitAction])))
        
        createBackgroundTiles()
    }
    
    private func spawnPlayer() {
        let player = Player()
        player.position = CGPoint(x: self.size.width / 2, y: player.size.height / 2)
        addChild(player)
    }
    
    func spawnEnemy() {
        let enemy = Enemy()
        let randomX = CGFloat.random(in: 0..<size.width)
        enemy.position = CGPoint(x: randomX, y: size.height + enemy.size.height / 2)
        addChild(enemy)
        enemies.append(enemy)
        
        if enemies.count > maxEnemies {
            removeOldestEnemy()
        }
        
        let moveDown = SKAction.moveBy(x: 0, y: -(size.height + enemy.size.height), duration: TimeInterval(enemySpeed))
        let sequence = SKAction.sequence([moveDown])
        enemy.run(sequence)
    }
    
    func spawnBullet(from node: SKNode, isEnemy: Bool, at location: CGPoint) {
        let bullet = Bullet(isEnemy: isEnemy)
        bullet.position = node.position
        addChild(bullet)
        
        let moveAction: SKAction
        if isEnemy {
            moveAction = SKAction.moveBy(x: 0, y: -size.height, duration: TimeInterval(bulletMoveSpeed))
        } else {
            moveAction = SKAction.moveBy(x: 0, y: size.height, duration: TimeInterval(bulletMoveSpeed))
        }
        let removeBulletAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeBulletAction])
        bullet.run(sequence)
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
        guard let firstTouch = touches.first else { return }
        
        // Add these lines to move the joystick base and stick to the touched location
        baseNode.position = firstTouch.location(in: self)
        stickNode.position = firstTouch.location(in: self)
        
        // リスタートボタンをタップしたかどうかを判定する
        if gameState == .gameOver && self.contains(firstTouch.location(in: self)) {
            restartGame()
            return
        }
        
        if baseNode.frame.contains(firstTouch.location(in: self)) {
            touch = firstTouch
        }
    }
    
    private func restartGame() {
        // 現在のシーンを再読み込みしてリスタートする
        if let currentScene = self.scene, let view = self.view {
            let transition = SKTransition.crossFade(withDuration: 0.5)
            let newScene = GameScene(size: self.size)
            view.presentScene(newScene, transition: transition)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touch else { return }
        
        let position = touch.location(in: self)
        let maxDistance: CGFloat = baseNode.size.width / 2
        let distance = sqrt(pow(position.x - baseNode.position.x, 2) + pow(position.y - baseNode.position.y, 2))
        let angle = atan2(position.y - baseNode.position.y, position.x - baseNode.position.x)
        
        if distance <= maxDistance {
            stickNode.position = position
        } else {
            stickNode.position.x = baseNode.position.x + cos(angle) * maxDistance
            stickNode.position.y = baseNode.position.y + sin(angle) * maxDistance
        }
        if distance <= maxDistance {
            stickNode.position = position
        } else {
            stickNode.position.x = baseNode.position.x + cos(angle) * maxDistance
            stickNode.position.y = baseNode.position.y + sin(angle) * maxDistance
        }
        isMoving = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touch, touches.contains(touch) {
            stickNode.position = baseNode.position
            self.touch = nil
            isMoving = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
        isMoving = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        // 以前の更新時間を取得し、現在の更新時間を保存
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Called before each frame is rendered
        if score >= stage * 100 {
            stage += 1
            enemySpawnInterval *= 0.9
            enemyMoveSpeed *= 0.9
        }
        
        // updatePlayerPosition を呼び出す際に deltaTime を渡す
        updatePlayerPosition(deltaTime: deltaTime)
        
        
        scrollBackgroundTiles()
        // Update camera position
        gameCamera.position.x = self.size.width / 2
        gameCamera.position.y = player.position.y
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.enemy {
            // PlayerとEnemyが衝突した場合の処理を記述
            if let playerNode = firstBody.node as? Player, let enemyNode = secondBody.node {
                playerNode.takeDamage()
                enemyNode.removeFromParent()
                gameState = .gameOver
                gameOver()
            }
        } else if firstBody.categoryBitMask == PhysicsCategory.enemy && secondBody.categoryBitMask == PhysicsCategory.playerBullet {
            // EnemyとPlayer Bulletが衝突した場合の処理を記述
            if let enemy = firstBody.node as? Enemy {
                enemy.health -= 1
                if enemy.health <= 0 {
                    enemy.removeFromParent()
                    score += 10
                }
            }
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == PhysicsCategory.playerBullet && secondBody.categoryBitMask == PhysicsCategory.enemy {
            // Player BulletとEnemyが衝突した場合の処理を記述
            if let enemy = secondBody.node as? Enemy {
                enemy.health -= 1
                if enemy.health <= 0 {
                    enemy.removeFromParent()
                }
            }
            firstBody.node?.removeFromParent()
        }
    }
    
    func gameOver() {
        // SKActionの実行を停止する
        removeAllActions()
        
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
    
    private func updatePlayerPosition(deltaTime: TimeInterval) {
        if isMoving {
            let speed: CGFloat = 500
            
            let angle = atan2(stickNode.position.y - baseNode.position.y, stickNode.position.x - baseNode.position.x)
            let distance = sqrt(pow(stickNode.position.x - baseNode.position.x, 2) + pow(stickNode.position.y - baseNode.position.y, 2))
            let maxDistance: CGFloat = baseNode.size.width / 2
            
            let velocity = distance / maxDistance
            
            let dx = cos(angle) * speed * velocity * CGFloat(deltaTime)
            let dy = sin(angle) * speed * velocity * CGFloat(deltaTime)
            
            player.position.x += dx
            player.position.y += dy
            
            // Add these lines to clamp the player's position
            player.position.x = min(max(player.position.x, player.size.width / 2), size.width - player.size.width / 2)
            player.position.y = player.position.y
        }
    }
    
    func createBackgroundTiles() {
        let tileCount = Int(ceil(size.height / backgroundTileHeight)) + 1
        for i in 0..<tileCount {
            let backgroundTile = SKSpriteNode(color: .gray, size: CGSize(width: size.width, height: backgroundTileHeight))
            backgroundTile.position = CGPoint(x: size.width / 2, y: CGFloat(i) * backgroundTileHeight)
            backgroundTile.zPosition = -1
            addChild(backgroundTile)
            backgroundTiles.append(backgroundTile)
        }
    }
    
    func scrollBackgroundTiles() {
        let cameraY = gameCamera.position.y
        for tile in backgroundTiles {
            if tile.position.y + backgroundTileHeight < cameraY - size.height / 2 {
                tile.position.y += backgroundTileHeight * CGFloat(backgroundTiles.count)
            }
        }
    }
    
    private func removeOldestEnemy() {
        if let enemyToRemove = enemies.first {
            enemyToRemove.removeFromParent()
            enemies.removeFirst()
        }
    }
}
