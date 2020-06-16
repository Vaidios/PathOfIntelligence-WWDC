//
//  Tools.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 12/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import Foundation

public struct Point {
    public let x: Int
    public let y: Int
    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    public static func -(lhs: Point, rhs: Point) -> Point {
        return Point(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    public static func +(lhs: Point, rhs: Point) -> Point {
        return Point(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    public static func ==(lhs: Point, rhs: Point) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y)
    }
}
