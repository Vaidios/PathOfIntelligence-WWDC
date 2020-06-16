//
//  SynapticChain.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 09/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import Foundation

public class SynapticChain {
    
    //let uuid: UInt
    let uuid: String
    static let maxLength: UInt = 192
    var isFinished: Bool = false {
        didSet {
            if isFinished && isFirstFinish {
                
                isFirstFinish = false
                completion(self)
            }
        }
    }
    private var isFirstFinish = true
    var isChecked: Bool = false
    let change: (SynapticChain) -> ()
    let completion: (SynapticChain) -> ()
    public init(_ firstSynapse: Synapse, onChange: @escaping (SynapticChain) -> (), onCompletion: @escaping (SynapticChain) -> ()) {
        self.change = onChange
        self.completion = onCompletion
        self.uuid = UUID().uuidString
        firstSynapse.synapticChain = self
        append(firstSynapse)
        expand()
    }
    public var firstNeuron: Neuron? {
        return chain.first?.axon.parentNeuron
    }
    public var lastNeuron: Neuron? {
        return chain.last?.dendrite.parentNeuron
    }
    
    public private(set) var chain: [Synapse] = [Synapse]() {
        didSet {
            if chain.count >= SynapticChain.maxLength {
                isFinished = true
//                completion(self)
            } else {
                change(self)
            }
        }
    }
    
    private func append(_ synapse: Synapse) {
        if !isFinished {
            chain.append(synapse)
        }
    }
    private(set) var isScrapable: Bool = false
    private func expand() {
        if !isFinished {
            guard let lastNeuron = lastNeuron else {
                isScrapable = true
                fatalError()
            }
            if let synapse = try? lastNeuron.attemptConnection() {
                append(synapse)
                synapse.synapticChain = self
                if synapse.isLastSynapse {
                    isFinished = true
                } else {
                    expand()
                }
            } else {
                isFinished = true
            }
        }
    }
    
    func contains(_ newSynapse: Synapse) -> Bool {
        let doesExist = chain.contains { (synapse) -> Bool in
            return synapse === newSynapse
        }
        return doesExist
    }
    
}
