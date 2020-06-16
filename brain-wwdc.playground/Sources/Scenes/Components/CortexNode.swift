//
//  CortexNode.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 11/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import SpriteKit

class CortexNode: SKNode {
    let binMap: BinaryImage
    let scale: (x: CGFloat, y: CGFloat)
    var nodeMap: [[SKNode?]]!
    var isLocked: Bool = false
    let type: BitmapManager.BitmapType
    init(with type: BitmapManager.BitmapType, scale: (x: CGFloat, y: CGFloat)) {
        self.type = type
        self.scale = scale
        binMap = BitmapManager.getMap(for: type)
        super.init()
        createNodeMap(from: binMap.bitmap)
    }
    private func scale(_ point: Point) -> CGPoint {
        return CGPoint(x: CGFloat(point.x) * scale.x, y: CGFloat(point.y) * scale.y)
    }
    
    func contains(_ point: Point) -> Bool {
        if let result = binMap.bitmap[safe: point.y]?[safe: point.x] {
            return !result
        } else {
            return false
        }
        
    }
    
    private func createNodeMap(from bitmap: [[Bool]]) {
        var map = [[SKNode?]]()
        for (y, row) in bitmap.enumerated() {
            var mapRow = [SKNode?]()
            for (x, bit) in row.enumerated() {
                if bit == false {
                    let scaledPoint = scale(Point(x, y))
                    let node = SKShapeNode(rect: CGRect(x: scaledPoint.x, y: scaledPoint.y, width: 1, height: 1), cornerRadius: 0.3)
                    switch type {
                    case .WWDCtop:
                        node.strokeColor = .vividElectricBlue
                    case .numberMiddle:
                        node.strokeColor = .electricYellow
                    default:
                        node.strokeColor = .electricAmber
                    }
                    node.alpha = 0
                    addChild(node)
                    mapRow.append(node)
                } else {
                    mapRow.append(nil)
                }
            }
            map.append(mapRow)
        }
        self.nodeMap = map
    }
    
    private func getNodeAt(_ point: Point) -> SKNode? {
        return nodeMap[point.y][point.x]
    }
    
    func sendImpulse(at centerPoint: Point, in radius: Int = 30) {
        if isLocked { return }
        guard let node = getNodeAt(centerPoint) else {
            print("[CortexNode] - Invalid point specified at nil")
            return
        }
        isLocked = true
        let time: TimeInterval = 0.7
        node.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: time)
        let fadeOut = SKAction.fadeOut(withDuration: time)
        let sequence = SKAction.sequence([fadeIn, fadeOut])
        node.run(sequence) {
        }
        
        
        func getLength(from p1: Point, to p2: Point) -> Float {
            let vector = p1 - p2
            return Float(vector.x * vector.x + vector.y * vector.y).squareRoot()
        }
        
        

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            var lastLength: Float = 0
            for n in  1 ..< radius {
                ///((2n+1)^2 - 1) - ((2(n-1) + 1)^2 - 1)
                let neuronsInLayer = n * (4 * n + 4) - ( (n - 1) * (4 * n) )
                var nilInLayer: Int = 0
                var dirVector: Point
                //Start from the edge on each radius change
                var currentPoint: Point = centerPoint + Point(-n, n)
                for nodeNo in 0 ..< neuronsInLayer {
                    switch nodeNo {
                    case 0 ..< 2 * n:
                        //turn right
                        dirVector = Point(1, 0)
                    case 1 * (2 * n) ..< 2 * (2 * n):
                        //turn down
                        dirVector = Point(0, -1)
                    case 2 * (2 * n) ..< 3 * (2 * n):
                        //turn left
                        dirVector = Point(-1, 0)
                    case 3 * (2 * n) ..< 4 * (2 * n):
                        //turn up
                        dirVector = Point(0, 1)
                    default:
                        print("Couldnt determine direction vector")
                        return
                    }
                    currentPoint = currentPoint + dirVector
                    guard let node = self.nodeMap[safe: currentPoint.y]?[safe: currentPoint.x] as? SKShapeNode else {
                        nilInLayer += 1
                        continue
                    }
                    let length = getLength(from: centerPoint, to: currentPoint)
                    lastLength = length
                    if  length <= Float(radius) {
                        let wait = SKAction.wait(forDuration: TimeInterval(length) * 0.05)
                        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: time)
                        
                        let fadeTo = SKAction.fadeAlpha(to: 0.2, duration: time)
                        let sequence = SKAction.sequence([wait, fadeIn, fadeTo])
                        node.run(sequence)
                    }
                }
            }
            let lastWait = SKAction.wait(forDuration: TimeInterval(lastLength) * 0.05 + time + time)
            let lastBlock = SKAction.customAction(withDuration: 0) { [weak self] (_, _) in
                guard let self = self else { return }
                self.isLocked = false
            }
            let lastSequence = SKAction.sequence([lastWait, lastBlock])
            self.run(lastSequence)
        }

        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
