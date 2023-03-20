//
//  PhysicsCategory.swift
//  DyingMan
//
//  Created by 田中大翔 on 2023/03/20.
//

import Foundation

struct PhysicsCategory: OptionSet {
    let rawValue: UInt32
    
    static let none = PhysicsCategory(rawValue: 0 << 0)
    static let player = PhysicsCategory(rawValue: 1 << 0)
    static let enemy = PhysicsCategory(rawValue: 1 << 1)
    static let playerBullet = PhysicsCategory(rawValue: 1 << 2)
    static let enemyBullet = PhysicsCategory(rawValue: 1 << 3)
}
