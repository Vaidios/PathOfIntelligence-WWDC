//
//  Neuron.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 09/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import Foundation

public class Neuron {
    var isEnabled = true
    let brain: Brain
    public let location: Point
    let id: UInt
    let dendrite = Dendrite()
    let axon = Axon()
    
    // Smell ID is an unique identifier that repells neurons with similiar smell, but attracts unknown
    var isSignificant: Bool = false
    
    public init(location: Point, in brain: Brain, direction: Direction = .multi) {
        self.location = location
        self.direction = direction
        self.id = UInt("\(location.x)\(location.y)")!
        self.brain = brain
        axon.set(parent: self)
        dendrite.set(parent: self)
        
    }
    func attemptConnection(withBusyNeuron: Bool = false) throws -> Synapse {
        do {
            let newSynapse = axon.wire(to: try scanForBestNeuron(in: direction).dendrite, with: self.id)
//            isEnabled = false
            return newSynapse
        } catch {
            throw error
        }
    }
    public enum NeuronError: Error {
        case noPath
    }
    
    public enum Direction: CaseIterable {
        case left, right, up, down, multi
    }
    
    var direction: Direction!
    func scanForBestNeuron(in direction: Direction, withBusyNeuron: Bool = false) throws -> Neuron {
        var neighbours = scanForNeurons(in: [direction])
        if neighbours.isEmpty {
            neighbours = brain.getNeighboursFor(point: location)
        }
        var bestNeuron: Neuron!
        var bestNeurons = [Neuron]()
        var busyNeurons = [Neuron]()
        var freeNeurons = [Neuron]()
        for neighbourNeuron in neighbours {
            if neighbourNeuron.isEnabled == false { continue }
            if let _ = neighbourNeuron.dendrite.synapses {
                if let selfSynapses = self.dendrite.synapses {
                    for selfSynapse in selfSynapses {
                        if neighbourNeuron.dendrite.containsSynapsesWith(uuid: selfSynapse.synapticChain!.uuid) {
                            continue
                        } else {
                            busyNeurons.append(neighbourNeuron)
                        }
                    }
                } else {
                    busyNeurons.append(neighbourNeuron)
                    continue
                }
            } else {
                let destination = neighbourNeuron.location
                let brainImportance = !BitmapManager.brainPixelMap.bitmap[destination.y][destination.x]
                if brainImportance  {
                    bestNeurons.append(neighbourNeuron)
                } else {
                    freeNeurons.append(neighbourNeuron)
                }
            }
        }
        if !bestNeurons.isEmpty {
            bestNeuron = bestNeurons[Int.random(in: 0 ..< bestNeurons.count)]
        } else if !freeNeurons.isEmpty {
            bestNeuron = freeNeurons[Int.random(in: 0 ..< freeNeurons.count)]
        } else if !busyNeurons.isEmpty {
            bestNeuron = busyNeurons[Int.random(in: 0 ..< busyNeurons.count)]
        }
        if bestNeuron == nil {
            throw NeuronError.noPath
        }
        bestNeuron.direction = self.direction
        return bestNeuron
    }
    
    func fire(signal: Signal) {
        signal.points.append(self.location)
        if !signal.isStopped {
            axon.transport(signal)
        }
        
    }
    
    func scanForNeurons(in directions: [Direction]) -> [Neuron] {
        let neighbours = brain.getNeighboursFor(point: self.location)
        var neurons = [Neuron]()
        for direction in directions {
            switch direction {
            case .up:
                neighbours.forEach { (neighbour) in
                    if neighbour.location.y > self.location.y {
                        if !neurons.contains(where: { (neuron) -> Bool in
                            neuron.location == neighbour.location
                        }) {
                            neurons.append(neighbour)
                        }
                    }
                }
            case .left:
                neighbours.forEach { (neighbour) in
                    if neighbour.location.x < self.location.x {
                        if !neurons.contains(where: { (neuron) -> Bool in
                            neuron.location == neighbour.location
                        }) {
                            neurons.append(neighbour)
                        }
                    }
                }
            case .right:
                neighbours.forEach { (neighbour) in
                    if neighbour.location.x > self.location.x {
                        if !neurons.contains(where: { (neuron) -> Bool in
                            neuron.location == neighbour.location
                        }) {
                            neurons.append(neighbour)
                        }
                    }
                }
            case .down:
                neighbours.forEach { (neighbour) in
                    if neighbour.location.y < self.location.y {
                        if !neurons.contains(where: { (neuron) -> Bool in
                            neuron.location == neighbour.location
                        }) {
                            neurons.append(neighbour)
                        }
                    }
                }
            case .multi:
                neighbours.forEach { (neighbour) in
                    if !neurons.contains(where: { (neuron) -> Bool in
                        neuron.location == neighbour.location
                    }) {
                        neurons.append(neighbour)
                    }
                }
                
            }
            
        }
        return neurons
    }
    
}
