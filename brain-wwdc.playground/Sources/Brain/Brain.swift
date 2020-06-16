//
//  Brain.swift
//  Brain
//
//  Created by Kamil Sosna on 27/04/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import Foundation


protocol BrainDelegate: class {
    func synapticChainDidChange(brain: Brain, synapticChain: SynapticChain)
    func synapticChainDidEnd(brain: Brain, synapticChain: SynapticChain)
    func signalDidFinish(signal: Signal)
    func brainDidFillUp(brain: Brain)
}

public class Brain {
    
    weak var delegate: BrainDelegate?
    var neuronMap: [[Neuron]] = [[Neuron]]()
    private(set) var synapticChains = [SynapticChain]()
    private(set) var enabledNeuronLocations = [Point]()
    public let map: BinaryImage

    //MARK: - Initialization
    public init(brainMap: BinaryImage, mask: BinaryImage, direction: Neuron.Direction = .multi) {
        self.map = brainMap
        neuronMap = createNeuronMatrix(with: brainMap, and: mask, direction: direction)
    }


    private func createNeuronMatrix(with brainMap: BinaryImage, and bitmask: BinaryImage, direction neuronDir: Neuron.Direction = .multi) -> [[Neuron]] {
        var returnNeurons = [[Neuron]]()
        for (y, row) in brainMap.bitmap.enumerated() {
            var neuronsRow = [Neuron]()
            for (x, bit) in row.enumerated() {
                let position = Point(x, y)
                let neuron = Neuron(location: position, in: self, direction: neuronDir)
                neuron.isEnabled = bitmask.bitmap[y][x]
                neuron.isSignificant = !bit
                neuronsRow.append(neuron)
                if neuron.isEnabled {
                    enabledNeuronLocations.append(position)
                }
            }
            returnNeurons.append(neuronsRow)
        }
        return returnNeurons
    }
    //MARK: - Neural genesis
//    let genesisQueue = DispatchQueue(label: "genesis")
    private(set) var genesisNeuronQueue = [Neuron]() {
        didSet {
            if !genesisNeuronQueue.isEmpty {
                growFromQueue()
            }
            
        }
    }
    func growFromQueue() {
        if genesisNeuronQueue.isEmpty { return }
        let neuron = genesisNeuronQueue.removeFirst()
        if let synapse = try? neuron.attemptConnection() {
            let synapticChain = SynapticChain(synapse, onChange: { [weak self] (chain) in
                if let self = self {
                    //onChange
                    self.delegate?.synapticChainDidChange(brain: self, synapticChain: chain)
                }
            }) { [weak self] (chain) in
                //onEnd
                if let self = self {
                    self.delegate?.synapticChainDidEnd(brain: self, synapticChain: chain)
                }
            }
            synapse.synapticChain = synapticChain
            synapticChains.append(synapticChain)
        } else {
            addRandomNeuronToQueue()
        }
        
    }
    func addNeuronToQueue(from point: Point, _ direction: Neuron.Direction = .multi) {
        if isFull { return }
        if let neuron = neuronMap[safe: point.y]?[safe: point.x] {
            if neuron.axon.synapse == nil {
                neuron.direction = direction
                genesisNeuronQueue.append(neuron)
            } else {
                print("[Brain] - Neuron has synapse on it's axon")
            }
        } else {
            print("[Brain] - No valid neuron at point \(point)")
        }
    }
    public var isFull = false {
        didSet {
            delegate?.brainDidFillUp(brain: self)
        }
    }
    public func addRandomNeuronToQueue(_ direction: Neuron.Direction = .multi) {
        if isFull { return }
        if enabledNeuronLocations.count < 23000 {
            isFull = true
        }
        var isFound = false
        while !isFound {
            if enabledNeuronLocations.isEmpty {
                print("[BRAIN] - No more enabled neurons locations")
                isFull = true
                return
            }
            let randomIndex = Int.random(in: 0 ..< enabledNeuronLocations.count)
            let point = enabledNeuronLocations.remove(at: randomIndex)
            let neuron = neuronMap[point.y][point.x]
            if neuron.axon.synapse == nil {
                if let neuronSynapses = neuron.dendrite.synapses {
                    if neuronSynapses.count != 0 {
                        continue
                    }
                }
                neuron.direction = direction
                genesisNeuronQueue.append(neuron)
                isFound = true
            }
        }
        
    }
    
    

    //MARK: - Signal propagation
    

    private let maxConcurentSignals = 20
    private var signalQueue: [Signal] = [Signal]()
    let signalPropagationQueue = DispatchQueue(label: "signal")
    
    func addToQueue(signalType: Signal.SignalType) {
        signalPropagationQueue.sync {
            if signalQueue.count < maxConcurentSignals {
                let signal = Signal(type: signalType) { [weak self] (signal) in
                    guard let self = self else { return }
                    self.delegate?.signalDidFinish(signal: signal)
                }
                signalQueue.append(signal)
            } else {
                return
            }
        }
        
    }
    public func fireSignal(at point: Point? = nil, isSynapticChainBeginning: Bool = true) {
        signalPropagationQueue.sync {
            if signalQueue.isEmpty {
                print("[Signal queue] - No signals in the queue")
                return
            }
            let signal = signalQueue.removeFirst()
            if let point = point {
                if let neuron = neuronMap[safe: point.y]?[safe: point.x] {
                    neuron.fire(signal: signal)
                }
                
            } else {
                if isSynapticChainBeginning {
                    if synapticChains.isEmpty { return }
                    let randIndex = Int.random(in: 0 ..< synapticChains.count)
                    if let neuron = synapticChains[randIndex].firstNeuron {
                        neuron.fire(signal: signal)
                    }
                } else {
                    var noOfMissed = 0
                    while true {
                        if noOfMissed > 50 { return }
                        if let randNeuron = neuronMap.randomElement()!.randomElement() {
                            if randNeuron.isEnabled && randNeuron.axon.synapse != nil {
                                randNeuron.fire(signal: signal)
                                return
                            } else {
                                noOfMissed += 1
                            }
                        } else { return }
                    }
                }

            }
        }
        
    }
    
    
    //MARK: - Pathfinding
    func getNeighboursFor(point: Point, radius: Int = 1) -> [Neuron]{
        var neighbours = [Neuron?]()
        
        neighbours.append(neuronMap[safe: point.y - 1]?[safe: point.x - 1])
        neighbours.append(neuronMap[safe: point.y - 1]?[safe: point.x])
        neighbours.append(neuronMap[safe: point.y - 1]?[safe: point.x + 1])
        neighbours.append(neuronMap[safe: point.y]?[safe: point.x - 1])
        neighbours.append(neuronMap[safe: point.y]?[safe: point.x + 1])
        neighbours.append(neuronMap[safe: point.y + 1]?[safe: point.x - 1])
        neighbours.append(neuronMap[safe: point.y + 1]?[safe: point.x])
        neighbours.append(neuronMap[safe: point.y + 1]?[safe: point.x + 1])

        var notNilNeighbours = [Neuron]()
        for neuron in neighbours {
            if let neuron = neuron {
                notNilNeighbours.append(neuron)
            }
        }
        return notNilNeighbours
    }
    
    func getNeuronsAround(center centerPoint: Point, radius: Int) -> [Neuron] {
        
        func getLength(from p1: Point, to p2: Point) -> Float {
            let vector = p1 - p2
            return Float(vector.x * vector.x + vector.y * vector.y).squareRoot()
        }
        
        var neurons = [Neuron]()
        neurons.append(getNeuronAt(centerPoint))
        for n in  1 ..< radius {
            ///((2n+1)^2 - 1) - ((2(n-1) + 1)^2 - 1)
            let neuronsInLayer = n * (4 * n + 4) - ( (n - 1) * (4 * n) )

            var dirVector: Point
            //Start from the edge on each radius change
            var currentPoint: Point = centerPoint + Point(-n, n)
            for neuronNo in 0 ..< neuronsInLayer {
                switch neuronNo {
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
                    return [Neuron]()
                }
                guard let neuron = neuronMap[safe: currentPoint.y]?[safe: currentPoint.x] else { continue }
                currentPoint = currentPoint + dirVector
                if getLength(from: centerPoint, to: currentPoint) >= Float(radius) {
                    neurons.append(neuron)
                }
            }
        }
        return neurons
    }
    func getNeuronAt(_ point: Point) -> Neuron {
        neuronMap[point.y][point.x]
    }
}
