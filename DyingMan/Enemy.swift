//
//  Enemy.swift
//  DyingMan
//
//  Created by 田中大翔 on 2023/03/20.
//

import Foundation
import SpriteKit

class Enemy: SKSpriteNode {
    private var isHit = false
    var health: Int = 3
    
    init() {
        let texture = SKTexture(imageNamed: "enemy")
        super.init(texture: texture, color: .clear, size: CGSize(width: texture.size().width * 0.5, height: texture.size().height * 0.5))
        self.name = "enemy"
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.playerBullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func takeDamage() {
        if !isHit {
            isHit = true
            health -= 1
            
            if health <= 0 {
                removeFromParent()
            } else {
                // 任意のアニメーションや効果を追加（例：点滅させる）
                let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                let fadeIn = SKAction.fadeIn(withDuration: 0.1)
                let sequence = SKAction.sequence([fadeOut, fadeIn])
                let repeatAction = SKAction.repeat(sequence, count: 3)
                run(repeatAction) { [weak self] in
                    self?.isHit = false
                }
            }
        }
    }
    
}
