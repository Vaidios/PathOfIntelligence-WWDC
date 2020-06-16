//
//  Dendrite.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 09/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import Foundation

public class Dendrite {
    public var parentNeuron: Neuron!
    
    //var synapse: Synapse?
    var synapses: [Synapse]? {
        didSet {
            if let synapses = synapses {
                if synapses.count > 1 {
                    //print("Has more than one synapse \(synapses.count) ")
                }
                
            }
        }
    }
    
    func isContainedInChainOf(_ neuronToCheck: Neuron) -> Bool {
        
        guard let selfSynapses = synapses else {
            print("Destination neuron doesn't have any synapses")
            return false
        }
        guard let synapsesToCheck = neuronToCheck.dendrite.synapses else {
            print("Initiating neuron doesn't have any synapse")
            return false
        }
        
        return selfSynapses.contains { (selfSynapse) -> Bool in
            return synapsesToCheck.contains { (synapseToCheck) -> Bool in
                return synapseToCheck.synapticChain!.uuid == selfSynapse.synapticChain!.uuid
            }
        }
        
    }
    
    func setSynapse(_ synapse: Synapse) {
        if self.synapses == nil {
            self.synapses = [synapse]
        } else {
            self.synapses?.append(synapse)
            //print("Dendrite already taken")
        }
    }
    
    func containsSynapsesWith(uuid: String) -> Bool {
        var result = false
        if let synapses = synapses {
            for synapse in synapses {
                if synapse.containts(uuid: uuid) {
                    result = true
                }
            }
        }
        return result
    }
    
    func set(parent neuron: Neuron) { parentNeuron = neuron }
    
    func forward(signal: Signal) {
        parentNeuron.fire(signal: signal)
    }
}
