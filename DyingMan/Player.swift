//
//  Player.swift
//  DyingMan
//
//  Created by 田中大翔 on 2023/03/20.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    private var isHit = false

    init() {
        let texture = SKTexture(imageNamed: "player")
        super.init(texture: texture, color: .clear, size: CGSize(width: texture.size().width * 0.2, height: texture.size().height * 0.2))
        self.name = "player"
        configurePhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configurePhysics() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.enemyBullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    func takeDamage() {
        if !isHit {
            isHit = true
            removeFromParent()
        }
    }
}
