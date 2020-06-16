//
//  ThirdScene.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 15/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import SpriteKit

class ThirdScene: SKScene {
    let map: BinaryImage
    let brain: Brain
    let onFinish: (() -> ())?
    let onBack: (() -> ())?
    let scaleX: CGFloat
    let scaleY: CGFloat
    let cortexes: [CortexNode]
    let brainNode = SKNode()
    
    init(size: CGSize, brain: Brain, onBack: (() -> ())? = nil, onFinish: (() -> ())? = nil) {
        self.onBack = onBack
        self.onFinish = onFinish
        self.brain = brain
        self.map = brain.map
        
        scaleY = size.height / CGFloat(map.height)
        scaleX = size.width / CGFloat(map.width)
        self.cortexes = [CortexNode(with: .numberMiddle, scale:
            (scaleX, scaleY)),
                         CortexNode(with: .WWDCtop, scale: (scaleX, scaleY))]
        super.init(size: size)
        cortexes.forEach { (cortexNode) in
            cortexNode.zPosition = 3
            addChild(cortexNode)
        }
        brainNode.zPosition = 3
        addChild(brainNode)
        backgroundColor = .black
        brain.delegate = self
        setupTapNode()
        hideTapNode()
        firstAnimationBlock(after: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var numberOfTaps = 0 {
        didSet {
            if numberOfTaps == 3 {
                hideTapNode()
            }
        }
    }
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !introductionIsPassed { return }
        if introductionIsPassed && betweenAnimationDidStart {
            betweenAnimationDidStart = false
            betweenAnimationBlock(after: 2)
        }
        if brain.isFull {
            if brainIsPassed  {
                hideTapNode()
                showTapNode(mode: false)
                brain.addToQueue(signalType: Signal.SignalType.allCases.randomElement()!)
                brain.addToQueue(signalType: Signal.SignalType.allCases.randomElement()!)
                brain.addToQueue(signalType: Signal.SignalType.allCases.randomElement()!)
                brain.addToQueue(signalType: Signal.SignalType.allCases.randomElement()!)
                brain.addToQueue(signalType: Signal.SignalType.allCases.randomElement()!)
                brain.fireSignal(at: nil, isSynapticChainBeginning: false)
                brain.fireSignal(at: nil, isSynapticChainBeginning: false)
                brain.fireSignal(at: nil, isSynapticChainBeginning: false)
                brain.fireSignal(at: nil, isSynapticChainBeginning: false)
                brain.fireSignal(at: nil, isSynapticChainBeginning: false)
            }
            

        } else {
            brain.addRandomNeuronToQueue(Neuron.Direction.allCases.randomElement()!)
            brain.addRandomNeuronToQueue(Neuron.Direction.allCases.randomElement()!)
            brain.addRandomNeuronToQueue(Neuron.Direction.allCases.randomElement()!)
        }
        
        numberOfTaps += 1
    }
    var introductionIsPassed = false {
        didSet {
            if introductionIsPassed {
                showTapNode(mode: true)
            }
        }
    }
    
    var brainIsPassed = false
    override func update(_ currentTime: TimeInterval) {
        if betweenAnimationDidFinish && brainIsPassed && !didInitateEnding {
            didInitateEnding = true
            secondAnimationBlock(after: 4)
        }
    }
    
    func firstAnimationBlock(after delay: TimeInterval) {
        var currentTime = delay
        currentTime += createLabel(beginWait: currentTime, with: "Now it is time for", speed: .slow, scale: 1.0, completion: nil)
        currentTime += createLabel(beginWait: currentTime, with: "Neural genesis!", speed: .slow, scale: 1.2) { [weak self] in
            guard let self = self else { return }
            self.introductionIsPassed = true
            self.betweenAnimationDidStart = true
        }
        
    }
    var betweenAnimationDidStart = false
    var betweenAnimationDidFinish = false
    var didInitateEnding = false {
        didSet {
            if didInitateEnding {
                if let completion = onFinish {
                    completion()
                }
            }
        }
    }
    func betweenAnimationBlock(after delay: TimeInterval) {
        var currentTime = delay
        currentTime += createLabel(beginWait: currentTime, with: "Process still under intensive research", speed: .ultraslow, scale: 1, completion: nil)
        currentTime += createLabel(beginWait: currentTime, with: "With a lot to uncover", speed: .ultraslow, scale: 1, completion: nil)
        currentTime += createLabel(beginWait: currentTime, with: "about", speed: .slow, scale: 1, completion: nil)
        currentTime += createLabel(beginWait: currentTime, with: "super", speed: .superfast)
        currentTime += createLabel(beginWait: currentTime, with: "intelligence?", speed: .ultraslow, scale: 1) { [weak self] in
            guard let self = self else { return }
            self.betweenAnimationDidFinish = true
        }
    }
    
    func secondAnimationBlock(after delay: TimeInterval) {
        var currentTime = delay
        currentTime += createLabel(beginWait: currentTime, with: "Maybe some stimulation?", speed: .superslow, scale: 1.2) { [weak self] in
            guard let self = self else { return }
            self.showTapNode(mode: true)
            self.brainIsPassed = true
        }
    }
    
    
    
    //MARK: - Tap node
    var tapNode: SKNode!
    
    func setupTapNode() {
        let label = SKLabelNode(text: "Tap")
        label.horizontalAlignmentMode = .center
        func setLabelBackground() {
            let labelBack = SKShapeNode(rect: CGRect(x: -label.frame.width / 2, y: -label.frame.height / 2,
            width: label.frame.width, height: label.frame.height), cornerRadius: 3)
            labelBack.removeFromParent()
            labelBack.strokeColor = .black
            labelBack.fillColor = .black
            labelBack.alpha = 0.68
            labelBack.zPosition = -1
            label.addChild(labelBack)
        }
        
        tapNode = label
        tapNode.zPosition = 3
        addChild(tapNode)
        
    }
    func showTapNode(mode isBig: Bool) {
        tapNode.removeAllActions()
        if isBig {
            tapNode.position = CGPoint(x: size.width / 2, y: size.height / 4)
            tapNode.setScale(1.2)
            tapNode.isHidden = false
            tapNode.alpha = 0
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let sequence = SKAction.sequence([fadeIn, fadeOut])
            let repeatForever = SKAction.repeatForever(sequence)
            tapNode.run(repeatForever)
        } else {
            tapNode.position = CGPoint(x: size.width / 2, y: 20)
            tapNode.setScale(0.7)
            tapNode.isHidden = false
            tapNode.alpha = 0
            let fadeIn = SKAction.fadeIn(withDuration: 1)
            let fadeOut = SKAction.fadeOut(withDuration: 1)
            let sequence = SKAction.sequence([fadeIn, fadeOut])
            let repeatForever = SKAction.repeatForever(sequence)
            tapNode.run(repeatForever)
        }
        
    }
    func hideTapNode() {
        tapNode.removeAllActions()
        tapNode.isHidden = true
    }
    
    func scale(_ point: Point) -> CGPoint {
        return CGPoint(x: CGFloat(point.x) * scaleX, y: CGFloat(point.y) * scaleY)
    }
    func checkSignificance(for pointA: Point, and pointB: Point, in bitmap: BinaryImage) -> Float {
        var result: Float = 0
        if !bitmap.bitmap[pointA.y][pointA.x] {
            result += 0.5
        }
        
        if !bitmap.bitmap[pointB.y][pointB.x] {
            result += 0.5
        }
        return result
    }
    var numberOfSynapticChains = 0
    
    func refresh() {
        let brainNodeFadeOut = SKAction.fadeOut(withDuration: 3)
        let brainNodeActionBlock = SKAction.customAction(withDuration: 0) { [weak self] _,_ in
            guard let self = self else { return }
            self.addBrainWithSignificance()
            
        }
        let brainNodeActionBlock1 = SKAction.customAction(withDuration: 0) { [weak self] _,_ in
            guard let self = self else { return }
            self.brainNode.removeAllChildren()
        }
        let brainNodeWait = SKAction.wait(forDuration: 1)
        let brainNodeSequence = SKAction.sequence([brainNodeActionBlock,brainNodeFadeOut, brainNodeActionBlock1, brainNodeWait])
        
        brainNode.run(brainNodeSequence) { [weak self] in
            guard let self = self else { return }
            guard let image = self.image(with: self) else { fatalError() }
            let spriteNode = SKSpriteNode(texture: SKTexture(image: image))
            spriteNode.isHidden = false
            spriteNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            self.addChild(spriteNode)
            self.brainNodeSignificance.removeAllChildren()
            self.brainNode.removeAllChildren()
        }
        
        
        
    }
    func image(with scene: SKScene) -> UIImage? {
        let bounds = scene.view?.bounds
        var image = UIImage()
        UIGraphicsBeginImageContextWithOptions(bounds!.size, true, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        scene.view?.drawHierarchy(in: bounds!, afterScreenUpdates: true)
        if let screenshot = UIGraphicsGetImageFromCurrentImageContext() {
            image = screenshot
        } else {
            fatalError()
        }
        return image
    }
    var brainNodeSignificance = SKNode()
    func addBrainWithSignificance() {
        brainNodeSignificance.zPosition = 2
        self.addChild(brainNodeSignificance)
        for chain in brain.synapticChains {
            let synapticChain = chain.chain
            for (idx, synapse) in synapticChain.enumerated() {
                let firstNeuronPos = synapse.axon.parentNeuron.location
                let secondNeuronPos = synapse.dendrite.parentNeuron.location
                let scaledFirstPos = scale(firstNeuronPos)
                let scaledSecondPos = scale(secondNeuronPos)
                let path = CGMutablePath()
                path.move(to: scaledFirstPos)
                path.addLine(to: scaledSecondPos)
                let node = SKShapeNode(path: path)
                node.alpha = 0
                node.lineWidth = 1
                let significance = checkSignificance(for: firstNeuronPos, and: secondNeuronPos, in: self.map)
                switch significance {
                case 0.5:
                    node.strokeColor = .gray
                case 1.0:
                    node.strokeColor = .white
                default:
                    node.strokeColor = .black
                    continue
                }
                brainNodeSignificance.addChild(node)
                let wait = SKAction.wait(forDuration: TimeInterval(idx) * 0.005)
                let fadeIn = SKAction.fadeIn(withDuration: 0.05)
                let actionArr = [wait, fadeIn]
                let sequence = SKAction.sequence(actionArr)
                node.run(sequence)
            }
        }
    }
    var isAnyCortexLocked: Bool {
        get {
            var result = false
            for cortex in cortexes {
                if cortex.isLocked {
                    result = true
                }
            }
            return result
        }
    }
}

extension ThirdScene: BrainDelegate {
    func brainDidFillUp(brain: Brain) {
        refresh()
        brainIsPassed = true
    }
    
    func synapticChainDidChange(brain: Brain, synapticChain: SynapticChain) {
        
    }
    
    func synapticChainDidEnd(brain: Brain, synapticChain: SynapticChain) {
        numberOfSynapticChains += 1
        let synapticChain = synapticChain.chain
        if synapticChain.isEmpty { return }
        for (idx, synapse) in synapticChain.enumerated() {
            let firstNeuronPos = synapse.axon.parentNeuron.location
            let secondNeuronPos = synapse.dendrite.parentNeuron.location
            let scaledFirstPos = scale(firstNeuronPos)
            let scaledSecondPos = scale(secondNeuronPos)
            let path = CGMutablePath()
            path.move(to: scaledFirstPos)
            path.addLine(to: scaledSecondPos)
            let node = SKShapeNode(path: path)
            node.alpha = 0
            node.lineWidth = 1
            node.strokeColor = .white
            brainNode.addChild(node)
            
            let wait = SKAction.wait(forDuration: TimeInterval(idx) * 0.025)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            var actionArr = [wait, fadeIn]
            if idx == synapticChain.endIndex - 1 {
                if numberOfTaps > 1 {
                    let lastAction = SKAction.customAction(withDuration: 0) { [weak self] (_, _) in
                        guard let self = self else { return }
                        self.brain.addRandomNeuronToQueue(Neuron.Direction.allCases.randomElement()!)
                    }
                    actionArr.append(lastAction)
                }
            }
            let sequence = SKAction.sequence(actionArr)
            node.run(sequence)
        }
    }
    
    func signalDidFinish(signal: Signal) {
        let points = signal.points
        for (idx, point) in points.enumerated() {
            if idx == points.endIndex - 1 { return }
            let firstPoint = point
            let secondPoint = points[idx + 1]
            for cortex in cortexes {
                if cortex.contains(firstPoint) {
                    if isAnyCortexLocked {
                        break
                    } else {
                        if !cortex.isLocked {
                            cortex.sendImpulse(at: firstPoint)
                        }
                    }
                }
            }
            let firstScaledPoint = scale(firstPoint)
            let secondScaledPoint = scale(secondPoint)
            let path = CGMutablePath()
            path.move(to: firstScaledPoint)
            path.addLine(to: secondScaledPoint)
            let node = SKShapeNode(path: path)
            node.alpha = 0
            node.lineWidth = 3
            node.zPosition = 2
            switch signal.type {
            case .glutamate:
                node.strokeColor = .electricBlue
            case .gaba:
                node.strokeColor = .electricYellow
            case .norepinephrine:
                node.strokeColor = .electricRed
            default:
                node.strokeColor = .vividElectricBlue
            }
            brainNodeSignificance.addChild(node)
            let wait = SKAction.wait(forDuration: TimeInterval(idx) * 0.02)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let wait1 = SKAction.wait(forDuration: 0.3)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let sequence = SKAction.sequence([wait, fadeIn, wait1, fadeOut])
            node.run(sequence) {
                node.removeFromParent()
            }
        }
    }
}
