//
//  BirdNode.swift
//  ios-spritekit-flappy-flying-bird
//
//  Created by Astemir Eleev on 02/05/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import SpriteKit

class BirdNode: SKSpriteNode, Updatable {
    
    // MARK: - Conformance to Updatable protocol
    
    var delta: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    
    // MARK: - Properties
    
    var flyTextures: [SKTexture]? = nil
    
    // MARK: - Initializers
    
    convenience init(animationTimeInterval: TimeInterval, withTextureAtlas named: String, size: CGSize) {
        var textures = [SKTexture]()
        
        // upload the texture atlas
        do {
            textures = try SKTextureAtlas.upload(named: named, beginIndex: 1) { name, index -> String in
                return "r_player\(index)"
            }
        } catch {
            debugPrint(#function + " thrown the errro while uploading texture atlas : ", error)
        }
        
        self.init(texture: textures.first, color: .clear, size: size)
        preparePhysicsBody()
        
        // attach texture atrlas and prepare animation
        self.flyTextures = textures
        self.texture = textures.first
        self.animate(with: animationTimeInterval)
    }
    
    // MARK: - Methods

    fileprivate func preparePhysicsBody() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.5)
        physicsBody?.categoryBitMask = PhysicsCategories.player.rawValue
        physicsBody?.contactTestBitMask = PhysicsCategories.pipe.rawValue | PhysicsCategories.gap.rawValue | PhysicsCategories.boundary.rawValue
        physicsBody?.collisionBitMask = PhysicsCategories.pipe.rawValue | PhysicsCategories.boundary.rawValue
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0.0
    }
    
    fileprivate func animate(with timing: TimeInterval) {
        guard let walkTextures = flyTextures else {
            return
        }
        
        let animateAction = SKAction.animate(with: walkTextures, timePerFrame: timing, resize: false, restore: true)
        let foreverAction = SKAction.repeatForever(animateAction)
        self.run(foreverAction)
    }
    
    // MARK: - Conformance to Updatable protocol
    
    func update(_ timeInterval: CFTimeInterval) {
        delta = lastUpdateTime == 0.0 ? 0.0 : timeInterval - lastUpdateTime
        lastUpdateTime = timeInterval
        
        guard let physicsBody = physicsBody else {
            return
        }
        
        let velocityX = physicsBody.velocity.dx
        let velocityY = physicsBody.velocity.dy
        let threshold: CGFloat = 280
        
        if velocityY > threshold {
            self.physicsBody?.velocity = CGVector(dx: velocityX, dy: threshold)
        }
        
        let velocityValue = velocityY * (velocityY < 0 ? 0.003 : 0.001)
        zRotation = velocityValue.clamp(min: -1, max: 0.0)
    }
    
}

extension BirdNode: Touchable {
    // MARK: - Conformance to Touchable protocol
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Apply an impulse to the DY value of the physics body of the bird
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 25))
    }
}

