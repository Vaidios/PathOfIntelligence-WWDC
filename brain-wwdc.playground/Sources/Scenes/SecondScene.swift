import SpriteKit

class SecondScene: SKScene {
    static let text1 = "Neuron"
    let text2 = "Neurons"
    let text3 = "How many neurons are in your brain?"
    let thousandText = "Thousand?"
    let millionText = "Million?"
    let billionText = "Billion?!"
    let countText = "86 000 000 000"
    
    let onBack: (() -> ())?
    let onForward: (() -> ())?
    let onFinish: (() -> ())?
    
    let quickFadeIn: TimeInterval = 0.5
    let quickFadeOut: TimeInterval = 0.5
    let quickWait: TimeInterval = 0.5
    
    let brain: Brain!
    var scaleX: CGFloat = 0
    var scaleY: CGFloat = 0
    
    let map: BinaryImage
    
    var genesisPoints = [Point]()
    var signalPoints = [Point]()
    
    var themeColor = UIColor(red: 48/255, green: 49/255, blue: 53/255, alpha: 1.0)
    init(size: CGSize, brain: Brain, onBack: (() -> ())? = nil, onForward: (() -> ())? = nil, onFinish: (() -> ())? = nil) {
        self.onBack = onBack
        self.onForward = onForward
        self.onFinish = onFinish
        self.brain = brain
        self.map = brain.map
        super.init(size: size)
        brain.delegate = self
        let frameSize = size
        scaleY = frameSize.height / CGFloat(map.height)
        scaleX = frameSize.width / CGFloat(map.width)
        genesisPoints = createGenesisPoints()
        signalPoints = createGenesisPoints()
        setupTapNode()
        showTapNode(mode: true)
    }
    //MARK: - Create genesis points
    func createGenesisPoints() -> [Point] {
        var genesisPoints = [Point]()
        let y = map.bitmap.endIndex - 1
        let lastRow = map.bitmap[y]
        
        let numberOfPoints = 20
        let distance = lastRow.count / numberOfPoints
        let initialPoint = lastRow.count / 2 + lastRow.count % 2
        var currentDistance = 0
        var currentPoint = initialPoint
        for i in 0 ..< numberOfPoints - 1 {
            currentDistance = distance * i
            if i % 2 == 0 {
                currentPoint = currentPoint - currentDistance
            } else {
                currentPoint = currentPoint + currentDistance
                
            }
            genesisPoints.append(Point(currentPoint, y))
        }
        return genesisPoints
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Touches began
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        brainAction()
        if isSignalUnlocked && isFirstSignalTap {
            fireAllInSequence()
            isFirstSignalTap = false
            isSignalUnlocked = true
            isActonPotentialScene = true
            hideTapNode()
            showTapNode(mode: false)
        }
        
    }
    
    var isGenesisUnlocked = true
    var isSignalUnlocked = false
    var isFirstSignalTap = true
    var isActonPotentialScene = false {
        didSet {
            if isActonPotentialScene {
                actionPotentialLabel()
            }
        }
    }
    var startedNeurons = 0 {
        didSet {
            if startedNeurons == 1 {
                isGenesisUnlocked = false
                hideTapNode()
                
            }
            if startedNeurons == 2 && finishedNeurons == 1 {
                _ = continueNeuronsLabel(after: 1.5)
                showTapNode(mode: false)
            }
            if startedNeurons == 3 {
                
            }
            if startedNeurons == createGenesisPoints().count {
                isGenesisUnlocked = false
                hideTapNode()
            }
            
        }
        
    }
    var finishedNeurons = 0 {
        didSet {
            if finishedNeurons == 1 {
                _ = beginNeuronLabel(after: 0.5)
            }
            if startedNeurons == 1 && finishedNeurons == 1 {
                isGenesisUnlocked = true
                showTapNode(mode: true, initFadeIn: 2)
            }
        }
    }
    func brainAction() {
        if signalPoints.isEmpty {
            signalPoints = createGenesisPoints()
        }
        if !genesisPoints.isEmpty {
            if isGenesisUnlocked {
                let point = genesisPoints.removeFirst()
                brain.addNeuronToQueue(from: point, .down)
            }
            
        } else {
            if isSignalUnlocked {
                if !signalPoints.isEmpty {
                    let point = signalPoints.removeFirst()
                    brain.addToQueue(signalType: Signal.SignalType.allCases.randomElement()!)
                    brain.fireSignal(at: point)
                    if signalPoints.isEmpty {
                        signalPoints = createGenesisPoints()
                    }
                }
            }
        }
    }
    func flushRemainingNeurons() {
        isGenesisUnlocked = false
        if genesisPoints.isEmpty { return }
        let upperBound = genesisPoints.count
        for _ in 0 ..< upperBound {
            let point = genesisPoints.removeFirst()
            brain.addNeuronToQueue(from: point, .down)
        }
        
    }
    func fireAllInSequence() {
        
        signalPoints = createGenesisPoints()
        var actionBlocks = [SKAction]()
        isSignalUnlocked = false
        let upperBound = signalPoints.count
        for i in 0 ..< upperBound {
            let point = signalPoints.removeFirst()
            let val = i / 2
            var type: Signal.SignalType
            if i % 2 == 0 {
                switch val % 6 {
                case 0:
                    type = .glutamate
                case 1:
                    type = .dopamine
                case 2:
                    type = .serotonine
                case 3:
                    type = .gaba
                case 4:
                    type = .acetylcholine
                case 5:
                    type = .norepinephrine
                default:
                    type = Signal.SignalType.allCases.randomElement()!
                }
            } else {
                switch val % 6 {
                case 0:
                    type = .glutamate
                case 1:
                    type = .dopamine
                case 2:
                    type = .serotonine
                case 3:
                    type = .gaba
                case 4:
                    type = .acetylcholine
                case 5:
                    type = .norepinephrine
                default:
                    type = Signal.SignalType.allCases.randomElement()!
                }
            }
            let block = SKAction.customAction(withDuration: 0.1) { [weak self] (_, _) in
                guard let self = self else { return }
                self.brain.addToQueue(signalType: type)
                self.brain.fireSignal(at: point)
            }
            actionBlocks.append(block)
        }
        let lastBlock = SKAction.customAction(withDuration: 0) { [weak self] (_, _) in
            guard let self = self else { return }
            self.isSignalUnlocked = true
        }
        actionBlocks.append(lastBlock)
        if actionBlocks.isEmpty {
            return
        }
        let sequence = SKAction.sequence(actionBlocks)
        self.run(sequence)
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
            labelBack.strokeColor = themeColor
            labelBack.fillColor = themeColor
            labelBack.alpha = 0.68
            labelBack.zPosition = -1
            label.addChild(labelBack)
        }
        setLabelBackground()
        
        tapNode = label
        tapNode.zPosition = 3
        addChild(tapNode)
        
    }
    func showTapNode(mode isBig: Bool, initFadeIn: TimeInterval = 0) {
        tapNode.removeAllActions()
        if isBig {
            tapNode.position = CGPoint(x: size.width / 2, y: size.height / 3)
            tapNode.setScale(1.5)
            tapNode.isHidden = false
            tapNode.alpha = 0
            let initialFadeIn = SKAction.wait(forDuration: initFadeIn)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let sequence = SKAction.sequence([fadeIn, fadeOut])
            let repeatForever = SKAction.repeatForever(sequence)
            let finalSequence = SKAction.sequence([initialFadeIn, repeatForever])
            tapNode.run(finalSequence)
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
        
    //MARK: - Neuron label
    let neuronLabel = SKLabelNode(text: text1)
    var backgroundNode: SKShapeNode!
    func beginNeuronLabel(after duration: TimeInterval) -> TimeInterval {
        
        backgroundNode = SKShapeNode(rect: neuronLabel.frame, cornerRadius: 3)
        neuronLabel.addChild(backgroundNode)
        backgroundNode.position = CGPoint(x: backgroundNode.frame.width / 2, y: 0)
        backgroundNode.fillColor = themeColor
        backgroundNode.strokeColor = themeColor
        backgroundNode.alpha = 0
        backgroundNode.zPosition = -1
        let backWait = SKAction.wait(forDuration: duration)
        let backAction = SKAction.fadeAlpha(to: 0.5, duration: quickFadeIn)
        let backSequence = SKAction.sequence([backWait, backAction])
        backgroundNode.run(backSequence)
        addChild(neuronLabel)
        neuronLabel.alpha = 0
        neuronLabel.position = CGPoint(x: size.width / 2 - neuronLabel.frame.width/2, y: size.height / 2)
        neuronLabel.horizontalAlignmentMode = .left
        neuronLabel.zPosition = 2
        neuronLabel.setScale(1.3)
        let wait1 = SKAction.wait(forDuration: duration)
        let fadeIn1 = SKAction.fadeIn(withDuration: quickFadeIn)
        let sequence = SKAction.sequence([wait1, fadeIn1])

        isGenesisUnlocked = false
        neuronLabel.run(sequence) {[weak self] in
            guard let self = self else { return }
            self.isGenesisUnlocked = true
            
        }
        return sequence.duration
    }

    //MARK: - Neuron"s" label
    func continueNeuronsLabel(after duration: TimeInterval = 0) -> TimeInterval{
        let label = SKLabelNode(text: text2)
        label.horizontalAlignmentMode = .left
        label.position = neuronLabel.position
        label.alpha = 0
        label.zPosition = 5
        addChild(label)
        let labelBack = SKShapeNode(rect: CGRect(x: 0, y: 0, width: label.frame.width, height: label.frame.height), cornerRadius: 3)
        label.addChild(labelBack)
        labelBack.strokeColor = themeColor
        labelBack.fillColor = themeColor
        labelBack.alpha = 0.5
        labelBack.zPosition = -1
        label.setScale(1.3)
        let wait = SKAction.wait(forDuration: duration)
        let action = SKAction.fadeIn(withDuration: quickFadeIn)
        let positionAction = SKAction.move(to: CGPoint(x: size.width / 2 - label.frame.width/2, y: size.height / 2), duration: 1.5)
        let actionBlock = SKAction.customAction(withDuration: 0) { [weak self] (_, _) in
            guard let self = self else { return }
            
            self.neuronLabel.removeFromParent()
        }
        let actionBlock2 = SKAction.customAction(withDuration: 0) { [weak self] (_, _) in
            guard let self = self else { return }
            self.isGenesisUnlocked = true
        }
        
        let wait1 = SKAction.wait(forDuration: 1)
        let fadeOut = SKAction.fadeOut(withDuration: quickFadeOut)
        let sequence = SKAction.sequence([wait, action, actionBlock, positionAction, actionBlock2, wait1, fadeOut])
        isGenesisUnlocked = false
        label.run(sequence) { [weak self] in

            guard let self = self else { return }
            self.isGenesisUnlocked = true
            self.animationBlock(delay: 0.5)
            label.removeFromParent()
        }
        return sequence.duration
    }
    //MARK: - Animation block
    func animationBlock(delay: TimeInterval) {
        var totalDuration: TimeInterval = delay
        totalDuration += howManyLabel(after: totalDuration)
        totalDuration += createLabel(beginWait: totalDuration, with: thousandText, speed: .fast, scale: 1.1)
        totalDuration += createLabel(beginWait: totalDuration, with: millionText, speed: .fast, scale: 1.3)
        totalDuration += createLabel(beginWait: totalDuration, with: billionText, speed: .fast, scale: 1.6)
        totalDuration += createLabel(beginWait: totalDuration, with: "Well", speed: .slow)
        totalDuration += countLabel(after: totalDuration)
//        totalDuration += createLabel(beginWait: totalDuration, with: "neurons", speed: .fast)
        totalDuration += createLabel(beginWait: totalDuration, with: "😮", speed: .fast)
        totalDuration += createLabel(beginWait: totalDuration, with: "Each has ~7 000 synapses", speed: .superslow)
        totalDuration += createLabel(beginWait: totalDuration, with: "It gives more than", speed: .superslow)

        totalDuration += createLabel(beginWait: totalDuration, with: "600 000 000 000 000 connections", speed: .superslow)
        totalDuration += createLabel(beginWait: totalDuration, with: "cool", speed: .medium) { [weak self] in
            guard let self = self else { return }
            self.flushRemainingNeurons()
            self.hideTapNode()
            self.showTapNode(mode: true)
            self.isSignalUnlocked = true
        }
        totalDuration += createLabel(beginWait: totalDuration, with: "These connections are used to send", speed: .superslow)
    }
    //MARK: - Second animation block
    func secondAnimationBlock(delay: TimeInterval) {
        var totalDuration = delay
        totalDuration += createLabel(beginWait: totalDuration, with: "Whenever you", speed: .superslow)
        totalDuration += createLabel(beginWait: totalDuration, with: "Work", speed: .fast) { [weak self] in
            guard let self = self else { return }
            self.brainAction()
        }
        totalDuration += createLabel(beginWait: totalDuration, with: "Create", speed: .fast, scale: 1.1) { [weak self] in
            guard let self = self else { return }
            self.brainAction()
            self.brainAction()
        }
        totalDuration += createLabel(beginWait: totalDuration, with: "Live", speed: .fast, scale: 1.2){ [weak self] in
            guard let self = self else { return }
            self.brainAction()
            self.brainAction()
            self.brainAction()
        }
        totalDuration += createLabel(beginWait: totalDuration, with: "Love", speed: .fast, scale: 1.3){ [weak self] in
            guard let self = self else { return }
            self.brainAction()
        }
        totalDuration += createLabel(beginWait: totalDuration, with: "Think.", speed: .fast, scale: 1.4){ [weak self] in
            guard let self = self else { return }
            self.brainAction()
            self.brainAction()
        }
        totalDuration += createLabel(beginWait: totalDuration, with: "Think..", speed: .fast, scale: 1.6){ [weak self] in
            guard let self = self else { return }
            self.fireAllInSequence()
        }
        totalDuration += createLabel(beginWait: totalDuration, with: "Think...", speed: .medium, scale: 1.8)
        totalDuration += createLabel(beginWait: totalDuration, with: "Neurons reinforce", speed: .superslow)
        totalDuration += createLabel(beginWait: totalDuration, with: "and you get smarter!", speed: .superslow, scale: 1.5)
        totalDuration += createLabel(beginWait: totalDuration, with: "So, please", speed: .superslow) {
            self.fireAllInSequence()
        }
        totalDuration += createLabel(beginWait: totalDuration, with: "never stop tapping!", speed: .superslow)
        totalDuration += createLabel(beginWait: totalDuration, with: "ekhm...", speed: .fast)
        totalDuration += createLabel(beginWait: totalDuration, with: "thinking!", speed: .superslow, scale: 1.5) { [weak self] in
            guard let self = self else { return }
            if let completion = self.onFinish {
                let actionSeq = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.fadeOut(withDuration: 3)])
                self.run(actionSeq) {
                    completion()
                }
                
            }
        }
    }
    //MARK: - How many neurons a brain has?
    func howManyLabel(after duration: TimeInterval) -> TimeInterval {
        let attrString = NSMutableAttributedString(string: text3)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: text3.count)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-UltraLight", size: 32.0)!], range: range)
        
        let label = SKLabelNode(text: text3)

        label.alpha = 0
        label.attributedText = attrString
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.numberOfLines = 0
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 5
        label.preferredMaxLayoutWidth = size.width - size.width / 15
        let labelBack = SKShapeNode(rect: CGRect(x: -label.frame.width / 2, y: -label.frame.height / 2, width: label.frame.width, height: label.frame.height), cornerRadius: 3)
        addChild(label)
        label.addChild(labelBack)
        labelBack.strokeColor = themeColor
        labelBack.fillColor = themeColor
        labelBack.alpha = 0.5
        labelBack.zPosition = -1
        let wait = SKAction.wait(forDuration: duration)
        let fadeIn = SKAction.fadeIn(withDuration: quickFadeIn)
        let wait1 = SKAction.wait(forDuration: 3)
        let fadeOut = SKAction.fadeOut(withDuration: quickFadeOut)
        let sequence = SKAction.sequence([wait, fadeIn, wait1, fadeOut])
        label.run(sequence)
        return sequence.duration - duration
    }
    
    //MARK: - Count to 86 000 000 000 label
    func countLabel(after duration: TimeInterval) -> TimeInterval {
        let label = SKLabelNode(text: "86")
                
        label.alpha = 0
                
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.numberOfLines = 0
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 5
        label.preferredMaxLayoutWidth = size.width - size.width / 15
        var labelBack = SKShapeNode(rect: CGRect(x: -label.frame.width / 2, y: -label.frame.height / 2,
                                                 width: label.frame.width, height: label.frame.height), cornerRadius: 3)
        addChild(label)
        label.addChild(labelBack)
        labelBack.strokeColor = themeColor
        labelBack.fillColor = themeColor
        labelBack.alpha = 0.5
        labelBack.zPosition = -1
        func setLabelBackground() {
            labelBack.removeFromParent()
            labelBack = SKShapeNode(rect: CGRect(x: -label.frame.width / 2, y: -label.frame.height / 2,
            width: label.frame.width, height: label.frame.height), cornerRadius: 3)
            labelBack.strokeColor = themeColor
            labelBack.fillColor = themeColor
            labelBack.alpha = 0.5
            labelBack.zPosition = -1
            label.addChild(labelBack)
        }
        
        let wait = SKAction.wait(forDuration: duration)
        let setScale = SKAction.scale(by: 1.08, duration: 0.01)
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let longWait = SKAction.wait(forDuration: 1)
        var waits = [SKAction]()
        for i in 1 ..< 10 {
            let j = 10 - i
            waits.append(SKAction.wait(forDuration: TimeInterval(j) * 0.07))
        }
        let block1 = SKAction.customAction(withDuration: 0) { (_, _) in
            label.text = "86 0"
            setLabelBackground()
        }
        let block2 = SKAction.customAction(withDuration: 0) { (_, _) in
            label.text = "86 00"
            setLabelBackground()
        }
        let block3 = SKAction.customAction(withDuration: 0) { (_, _) in
            label.text = "86 000"
            setLabelBackground()
        }
        let block4 = SKAction.customAction(withDuration: 0) { (_, _) in
            label.text = "86 000 0"
            setLabelBackground()
        }
        let block5 = SKAction.customAction(withDuration: 0) { (_, _) in
            label.text = "86 000 00"
            setLabelBackground()
        }
        let block6 = SKAction.customAction(withDuration: 0) { (_, _) in
            label.text = "86 000 000"
            setLabelBackground()
        }
        let block7 = SKAction.customAction(withDuration: 0) { (_, _) in
            label.text = "86 000 000 0"
            setLabelBackground()
        }
        let block8 = SKAction.customAction(withDuration: 0) { (_, _) in
            label.text = "86 000 000 00"
            setLabelBackground()
        }
        let block9 = SKAction.customAction(withDuration: 0) { (_, _) in
            label.text = "86 000 000 000 neurons"
            setLabelBackground()
        }
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let firstPartSeq: [SKAction] = [wait, fadeIn, setScale, waits[0], block1, waits[1], setScale, block2, waits[2], setScale, block3]
        let secondPartSeq = [waits[3], block4, setScale, waits[4], block5, setScale, waits[5], block6, setScale, waits[6]]
        let thirdPartSeq = [block7, waits[7], block8, waits[8], block9, longWait, fadeOut]
        let finalSequence = firstPartSeq + secondPartSeq + thirdPartSeq
        let sequence = SKAction.sequence(finalSequence)
        label.run(sequence)
        return sequence.duration - duration
    }
    
    //MARK: - Action potential label
    func actionPotentialLabel() {
        let actionText = "Action"
        var coloredActionAttrStrings = [NSAttributedString]()
        
        for _ in 0 ..< 6 {
            let actionAttrString = NSMutableAttributedString(string: actionText)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let range = NSRange(location: 0, length: actionText.utf16.count)
            actionAttrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
            actionAttrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.randomElectricColor, NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-UltraLight", size: 35.0)!], range: range)
            coloredActionAttrStrings.append(actionAttrString)
        }
        
        
        let actionAttrString = NSMutableAttributedString(string: actionText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: actionText.utf16.count)
        actionAttrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        actionAttrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-UltraLight", size: 35.0)!], range: range)
        let parentNode = SKNode()
        let actionLabel = SKLabelNode(attributedText: actionAttrString)
        let actionLabelBack = SKShapeNode(rect: CGRect(x: -actionLabel.frame.width / 2, y: 0, width: actionLabel.frame.width, height: actionLabel.frame.height))
        actionLabel.addChild(actionLabelBack)
        actionLabelBack.strokeColor = themeColor
        actionLabelBack.fillColor = themeColor
        actionLabelBack.alpha = 0.5
        actionLabelBack.zPosition = -1
        
        
        
        actionLabel.horizontalAlignmentMode = .center
        actionLabel.verticalAlignmentMode = .bottom
        parentNode.addChild(actionLabel)
        
        let potentialText = "Potential"
        var coloredPotentialAttrStrings = [NSAttributedString]()
        for _ in 0 ..< 6 {
            let potentialAttrString = NSMutableAttributedString(string: potentialText)
            let range1 = NSRange(location: 0, length: potentialText.utf16.count)
            potentialAttrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range1)
            potentialAttrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.randomElectricColor, NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-UltraLight", size: 35.0)!], range: range1)
            coloredPotentialAttrStrings.append(potentialAttrString)
        }
        let potentialAttrString = NSMutableAttributedString(string: potentialText)
        let range1 = NSRange(location: 0, length: potentialText.utf16.count)
        potentialAttrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range1)
        potentialAttrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-UltraLight", size: 35.0)!], range: range1)
        
        let potentialLabel = SKLabelNode(attributedText: potentialAttrString)
        

        
        let potentialLabelBack = SKShapeNode(rect: CGRect(x: -potentialLabel.frame.width / 2, y: -potentialLabel.frame.height, width: potentialLabel.frame.width, height: potentialLabel.frame.height))
        potentialLabelBack.strokeColor = themeColor
        potentialLabelBack.fillColor = themeColor
        potentialLabelBack.alpha = 0.5
        potentialLabelBack.zPosition = -1
        potentialLabel.addChild(potentialLabelBack)
        potentialLabel.horizontalAlignmentMode = .center
        potentialLabel.verticalAlignmentMode = .top
        parentNode.addChild(potentialLabel)
        
        let actionColorAction = SKAction.customAction(withDuration: 0) { (node, _) in
            if let node = node as? SKLabelNode {
                node.attributedText = coloredActionAttrStrings.randomElement()!
            }
        }
        let potentialColorAction = SKAction.customAction(withDuration: 0) { (node, _) in
            if let node = node as? SKLabelNode {
                node.attributedText = coloredPotentialAttrStrings.randomElement()!
            }
        }
        let wait = SKAction.wait(forDuration: 0.05)
        let actionSequence = SKAction.sequence([wait, actionColorAction, wait])
        let potentialSequence = SKAction.sequence([wait, potentialColorAction, wait])
        actionLabel.run(SKAction.repeatForever(actionSequence))
        potentialLabel.run(SKAction.repeatForever(potentialSequence))
        parentNode.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        parentNode.setScale(2)
        addChild(parentNode)
        parentNode.zPosition = 5
        let parentWait = SKAction.wait(forDuration: 2.5)
        let parentFireAction = SKAction.customAction(withDuration: 0) { [weak self] (_, _) in
            guard let self = self else { return }
            self.fireAllInSequence()
        }
        let parentFadeout = SKAction.fadeOut(withDuration: 0.2)
        let parentSequence = SKAction.sequence([parentWait, parentFireAction, parentWait,
                                                parentFireAction, parentWait, parentFadeout])
        parentNode.run(parentSequence) { [weak self] in
            
            guard let self = self else { return }
            self.isActonPotentialScene = false
            self.secondAnimationBlock(delay: 0.5)
            parentNode.removeFromParent()
        }
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
    let serialQueue = DispatchQueue(label: "serial")
}

extension SecondScene: BrainDelegate {
    func brainDidFillUp(brain: Brain) {
        
    }
    
    func synapticChainDidChange(brain: Brain, synapticChain: SynapticChain) {
        
    }
    //MARK: - SynapticChainDidEnd
    func synapticChainDidEnd(brain: Brain, synapticChain: SynapticChain) {
        for (idx, synapse) in synapticChain.chain.enumerated() {
            let firstPrescaledPoint = synapse.axon.parentNeuron.location
            let secondPrescaledPoint = synapse.dendrite.parentNeuron.location
            let firstPoint = scale(firstPrescaledPoint)
            let secondPoint = scale(secondPrescaledPoint)
            let significance = checkSignificance(for: firstPrescaledPoint, and: secondPrescaledPoint, in: BitmapManager.getMap(for: .cleanCanvas))
            let path = CGMutablePath()
            path.move(to: firstPoint)
            path.addLine(to: secondPoint)
            let node = SKShapeNode(path: path)
            node.alpha = 0
            node.lineWidth = 1
            switch significance {
            case 0.5:
                node.strokeColor = .gray
            case 1.0:
                node.strokeColor = .white
            default:
                node.strokeColor = .black
            }
            addChild(node)
            let wait = SKAction.wait(forDuration: TimeInterval(idx) * 0.01)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let sequence = SKAction.sequence([wait, fadeIn])
            if idx == synapticChain.chain.count - 1 {
                node.run(sequence) { [weak self] in
                    guard let self = self else { return }
                    self.finishedNeurons += 1
                }
            } else {
                node.run(sequence)
            }
            if idx == 0 {
                startedNeurons += 1
            }
        }
    }
    //MARK: - SignalDidFinish
    func signalDidFinish(signal: Signal) {
        let points = signal.points
        for (idx, point) in points.enumerated() {
            if !(idx == points.count - 1) {
                let firstPrescaledPoint = point
                let secondPrescaledPoint = points[idx + 1]
                let firstPoint = scale(firstPrescaledPoint)
                let secondPoint = scale(secondPrescaledPoint)
                let path = CGMutablePath()
                path.move(to: firstPoint)
                path.addLine(to: secondPoint)
                let node = SKShapeNode(path: path)
                node.alpha = 0
                node.lineWidth = 6
                
                switch signal.type {
                case .glutamate:
                    node.strokeColor = .electricBlue
                case .gaba:
                    node.strokeColor = .electricYellow
                case .norepinephrine:
                    node.strokeColor = .electricRed
                case .dopamine:
                    node.strokeColor = .electricBrightBlue
                case .serotonine:
                    node.strokeColor = .electricBrightGreen
                case .acetylcholine:
                    node.strokeColor = .electricAmber
                }
                addChild(node)
                let wait = SKAction.wait(forDuration: TimeInterval(idx) * 0.01)
                let fadeIn = SKAction.fadeIn(withDuration: 0.2)
                let wait1 = SKAction.wait(forDuration: 0.15)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let sequence = SKAction.sequence([wait, fadeIn, wait1, fadeOut])
                node.run(sequence) {
                    node.removeFromParent()
                }
            }
        }
    }
    
    
}
