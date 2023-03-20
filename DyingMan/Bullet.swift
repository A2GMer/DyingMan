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
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = isEnemy ? "enemyBullet" : "playerBullet"
        self.physicsBody = SKPhysicsBody(texture: texture, size: self.size)
        self.physicsBody?.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
