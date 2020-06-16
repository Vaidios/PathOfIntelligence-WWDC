//
//  Extensions.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 10/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import UIKit
import SpriteKit

extension UIColor {
    static var electricRed: UIColor {
        return UIColor(red: 255/255, green: 0, blue: 63/255, alpha: 1)
    }
    static var electricBlue: UIColor {
        return UIColor(red: 0/255, green: 111/255, blue: 255/255, alpha: 1)
    }
    static var electricBrightBlue: UIColor {
        return UIColor(red: 19/255, green: 244/255, blue: 239/255, alpha: 1)
    }
    static var electricBrightGreen: UIColor {
        return UIColor(red: 104/255, green: 255/255, blue: 0/255, alpha: 1)
    }
    static var electricAmber: UIColor {
        return UIColor(red: 255/255, green: 191/255, blue: 0/255, alpha: 1)
    }
    static var electricYellow: UIColor {
        return UIColor(red: 250/255, green: 255/255, blue: 0, alpha: 1)
    }
    static var vividElectricBlue: UIColor {
        return UIColor(red: 62/255, green: 202/255, blue: 232/255, alpha: 1)
    }
    
    static var randomElectricColor: UIColor {
        return [electricRed, electricBlue, electricBrightBlue, electricBrightGreen, electricAmber, electricYellow].randomElement()!
    }
    func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)

            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    static func ==(lhs: UIColor, rhs: UIColor) -> Bool {
        return (lhs.rgb()!.red == rhs.rgb()!.red) && (lhs.rgb()!.blue == rhs.rgb()!.blue) && (lhs.rgb()!.green == rhs.rgb()!.green)
    }
}

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension SKScene {
        //MARK: - Create label method
    enum Speed {
        case ultraslow, superslow, slow, fast, medium, superfast
    }
        func createLabel(beginWait duration: TimeInterval, with text: String, speed: Speed, scale: CGFloat = 1, completion: (() -> Void)? = nil) -> TimeInterval {
            
            let attrString = NSMutableAttributedString(string: text)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let range = NSRange(location: 0, length: text.utf16.count)
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
            attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-UltraLight", size: 32.0)!], range: range)
            let label = SKLabelNode(attributedText: attrString)
                    
            label.alpha = 0
                    
            label.position = CGPoint(x: size.width / 2, y: size.height / 2)
            label.numberOfLines = 0
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.zPosition = 5
            label.preferredMaxLayoutWidth = size.width - size.width / 15
            let labelBack = SKShapeNode(rect: CGRect(x: -label.frame.width / 2, y: -label.frame.height / 2,
                                                     width: label.frame.width, height: label.frame.height), cornerRadius: 3)
            addChild(label)
            label.addChild(labelBack)
            labelBack.strokeColor = UIColor(red: 48/255, green: 49/255, blue: 53/255, alpha: 1.0)
            labelBack.fillColor = UIColor(red: 48/255, green: 49/255, blue: 53/255, alpha: 1.0)
            labelBack.alpha = 0.8
            labelBack.zPosition = -1
            label.setScale(scale)
            var waitSpeed: TimeInterval
            switch speed {
            case .ultraslow:
                waitSpeed = 4
            case .superslow:
                waitSpeed = 2
            case .slow:
                waitSpeed = 1
            case .medium:
                waitSpeed = 0.5
            case .fast:
                waitSpeed = 0.25
            case .superfast:
                waitSpeed = 0.1
            }
            let wait = SKAction.wait(forDuration: duration)
            let fadeIn = SKAction.fadeIn(withDuration: 0.1)
            let wait1 = SKAction.wait(forDuration: waitSpeed)
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            let sequence = SKAction.sequence([wait, fadeIn, wait1, fadeOut])
            label.run(sequence) {
                if let completion = completion {
                    completion()
                }
                label.removeFromParent()
            }
            return sequence.duration - duration
        }
        //MARK: - Create label method end
}

class NeuButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addNeuToButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                 setState()
            } else {
                 resetState()
            }
        }
    }
    
    override open var isEnabled: Bool {
        didSet{
            if isEnabled == false {
                print("Button isnt enabled")
                setState()
            } else {
                resetState()
            }
        }
    }
    
    func setState(){
        self.layer.shadowOffset = CGSize(width: -2, height: -2)
        self.layer.sublayers?[0].shadowOffset = CGSize(width: 2, height: 2)
        self.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 0)
    }
    
    func resetState(){
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.sublayers?[0].shadowOffset = CGSize(width: -2, height: -2)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 2)
    }
    
    public func addNeuToButton(cornerRadius: CGFloat = 15.0, themeColor: UIColor = UIColor(red: 48/255, green: 49/255, blue: 53/255, alpha: 1.0)) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize( width: 2, height: 2)
        self.layer.shadowColor = UIColor(red: 62/255, green: 63/255, blue: 70/255, alpha: 1.0).cgColor
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = bounds
        shadowLayer.backgroundColor = themeColor.cgColor
        shadowLayer.shadowColor = UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1).cgColor
        shadowLayer.cornerRadius = cornerRadius
        shadowLayer.shadowOffset = CGSize(width: -2.0, height: -2.0)
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 2
        self.layer.insertSublayer(shadowLayer, below: self.imageView?.layer)
    }
}

