//
//  Bullet.swift
//  DyingMan
//
//  Created by 田中大翔 on 2023/03/20.
//

import Foundation
import SpriteKit

class Bullet: SKSpriteNode {
    init(isEnemy: Bool) {
        let texture = SKTexture(imageNamed: isEnemy ? "enemyBullet" : "playerBullet")
        super.init(texture: texture, color: .clear, size: CGSize(width: texture.size().width * 0.5, height: texture.size().height * 0.5))
        self.name = isEnemy ? "enemyBullet" : "playerBullet"
        self.physicsBody = SKPhysicsBody(texture: texture, size: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        
        configurePhysicsBody(isEnemy: isEnemy)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurePhysicsBody(isEnemy: Bool) {
        if isEnemy {
            self.physicsBody?.categoryBitMask = PhysicsCategory.enemyBullet
            self.physicsBody?.contactTestBitMask = PhysicsCategory.player
            self.physicsBody?.collisionBitMask = PhysicsCategory.player
        } else {
            self.physicsBody?.categoryBitMask = PhysicsCategory.playerBullet
            self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
            self.physicsBody?.collisionBitMask = PhysicsCategory.enemy
        }
    }
}
