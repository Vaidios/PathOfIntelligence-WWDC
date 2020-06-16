import SpriteKit



public class FirstScene: SKScene {
    var isFinished = false
    
    let text1 = "What's on your mind?"
    let texts2 = ["Creation?", "Innovation?", "Improvement?", "Happiness?", "Sadness?", "Memes?"]
    let text3 = "Probably quite a lot"
    let text4 = "But"
    let text5 = "What's \"in\" your mind?"
    let completion: () -> ()
    var themeColor = UIColor(red: 48/255, green: 49/255, blue: 53/255, alpha: 1.0)
    public init(size: CGSize, completion: @escaping () -> ()) {
        self.completion = completion
        super.init(size: size)
        backgroundColor = themeColor
        
        var totalDuration: TimeInterval = 0
        totalDuration += firstAnimation()
    }
    
    func firstAnimation() -> TimeInterval {
        var totalDuration: TimeInterval = 0
        
        let firstLabelTime = TimeInterval(4)
        let label1 = SKLabelNode(text: text1)
        label1.alpha = 0
        label1.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let wait1 = SKAction.wait(forDuration: 1)
        let fadeIn1 = SKAction.fadeIn(withDuration: firstLabelTime / 4)
        let wait11 = SKAction.wait(forDuration: firstLabelTime / 2)
        let fadeOut1 = SKAction.fadeOut(withDuration: firstLabelTime / 4)
        let sequence1 = SKAction.sequence([wait1, fadeIn1, wait11, fadeOut1])
        totalDuration += sequence1.duration
        addChild(label1)
        label1.run(sequence1) {
            label1.removeFromParent()
        }
        
        
        for text in texts2 {
            let label = SKLabelNode(text: text)
            label.position = CGPoint(x: size.width / 2, y: size.height / 2)
            label.alpha = 0
            let duration = TimeInterval(0.2)
            let wait = SKAction.wait(forDuration: totalDuration)
            let fadeIn2 = SKAction.fadeIn(withDuration: duration / 2)
            let wait2 = SKAction.wait(forDuration: duration)
            let fadeOut2 = SKAction.fadeOut(withDuration: duration / 2)
            let sequence = SKAction.sequence([wait, fadeIn2, wait2, fadeOut2])
            totalDuration += fadeIn2.duration
            totalDuration += wait2.duration
            totalDuration += fadeOut2.duration
            addChild(label)
            label.run(sequence) {
                label.removeFromParent()
            }
        }
        let label2 = SKLabelNode(text: text3)
        label2.alpha = 0
        label2.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let wait2 = SKAction.wait(forDuration: totalDuration)
        let fadeIn2 = SKAction.fadeIn(withDuration: firstLabelTime / 1.2)
        let wait21 = SKAction.wait(forDuration: 1)
        let fadeOut2 = SKAction.fadeOut(withDuration: firstLabelTime / 3)
        let sequence2 = SKAction.sequence([wait2, fadeIn2, wait21, fadeOut2])
        addChild(label2)
        totalDuration += sequence2.duration - wait2.duration
        label2.run(sequence2) {
            label2.removeFromParent()
        }
        label2.run(sequence2)
        
        let label3 = SKLabelNode(text: text4)
        label3.alpha = 0
        label3.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let wait3 = SKAction.wait(forDuration: totalDuration)
        let fadeIn3 = SKAction.fadeIn(withDuration: 0.1)
        let wait31 = SKAction.wait(forDuration: 0.5)
        let fadeOut3 = SKAction.fadeOut(withDuration: 0.1)
        let sequence3 = SKAction.sequence([wait3, fadeIn3, wait31, fadeOut3])
        totalDuration += sequence3.duration - wait3.duration
        addChild(label3)
        label3.run(sequence3) {
            label3.removeFromParent()
        }
        
        let label4 = SKLabelNode(text: text5)
        label4.alpha = 0
        label4.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let wait4 = SKAction.wait(forDuration: totalDuration)
        let fadeIn4 = SKAction.fadeIn(withDuration: 0.5)
        let wait41 = SKAction.wait(forDuration: 2)
        let fadeOut4 = SKAction.fadeOut(withDuration: 0.1)
        let sequence4 = SKAction.sequence([wait4, fadeIn4, wait41, fadeOut4])
        totalDuration += sequence4.duration - wait4.duration
        addChild(label4)
        label4.run(sequence4) {
            self.completion()
            self.removeFromParent()
            label4.removeFromParent()
        }
        
        return totalDuration
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

