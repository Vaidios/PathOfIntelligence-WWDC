//
//  ImageConverter.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 07/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import Foundation


public class BitmapManager {
    public enum BitmapType {
        case brain, mask, WWDCtop, WWDCmiddle, numberMiddle, cleanCanvas, revCleanCanvas
    }
    static private let width = 200
    static private let height = 192
    static let brainPixelMap = binaryStringDataToImageArray(string: BrainPixelMap, width: width)
    static let bitmaskMap = binaryStringDataToImageArray(string: BitMaskMap, width: width)
    static let wwdcTopMap = binaryStringDataToImageArray(string: WWDCtopMap, width: width)
    static let wwdcMiddleMap = binaryStringDataToImageArray(string: WWDCmiddleMap, width: width)
    static let numberMiddleMap = binaryStringDataToImageArray(string: NumberMiddleMap, width: width)
    static let cleanCanvasMap = createCleanCanvasMap()
    static let revCanvasMap = getMask(cleanCanvasMap)
    
    static public func getMap(for type: BitmapType) -> BinaryImage {
        switch type {
        case .brain:
            return brainPixelMap
        case .mask:
            return bitmaskMap
        case .WWDCtop:
            return wwdcTopMap
        case .WWDCmiddle:
            return wwdcMiddleMap
        case .numberMiddle:
            return numberMiddleMap
        case .cleanCanvas:
            return cleanCanvasMap
        case .revCleanCanvas:
            return revCanvasMap
        }
        
        
    }
    
    static func getMask(_ binImage: BinaryImage) -> BinaryImage {
        var retArr = [[Bool]]()
        for row in binImage.bitmap {
            var retRow = [Bool]()
            for bit in row {
                retRow.append(!bit)
            }
            retArr.append(retRow)
        }
        return BinaryImage(retArr, width: binImage.width, height: binImage.height)
    }
    
    private static func binaryStringDataToImageArray(string: String, width: Int, padding: Bool = false) -> BinaryImage {
        
        var binaryArray2D = [[Bool]]()
        var row = [Bool]()
        //Top padding
        if padding {
            let paddingRow = Array.init(repeating: true, count: width + 2)
            binaryArray2D.append(paddingRow)
        }
        for bit in string {
            if bit == "1" {
                row.append(true)
            } else if bit == "0" {
                row.append(false)
            }
            if row.count == width {
                if padding {
                    row.insert(true, at: 0)
                    row.append(true)
                }
                
                binaryArray2D.append(row)
                row = [Bool]()
            }
        }
        //Bottom padding
        if padding {
            let paddingRow = Array.init(repeating: true, count: width + 2)
            binaryArray2D.append(paddingRow)
        }
        let binImage = BinaryImage(binaryArray2D.reversed(), width: binaryArray2D.first!.count, height: binaryArray2D.count)
        return binImage
    }
    
    static func createCleanCanvasMap() -> BinaryImage {
        let map = [[Bool]].init(repeating: [Bool].init(repeating: false, count: BitmapManager.width), count: BitmapManager.height)
        let binImage = BinaryImage(map, width: BitmapManager.width, height: BitmapManager.height)
        return binImage
        
    }
}

public struct BinaryImage {
    public let bitmap: [[Bool]]
    public let width: Int
    public let height: Int
    
    init(_ binaryImageArray: [[Bool]], width: Int, height: Int) {
        self.bitmap = binaryImageArray
        self.width = width
        self.height = height
    }

}
