//
//  PhysicsCategory.swift
//  DyingMan
//
//  Created by 田中大翔 on 2023/03/20.
//

import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1
    static let enemy: UInt32 = 0b10
    static let playerBullet: UInt32 = 0b100
    static let enemyBullet: UInt32 = 0b1000
}
