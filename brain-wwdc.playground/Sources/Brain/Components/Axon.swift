//
//  Axon.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 09/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import Foundation

public class Axon {
    var synapse: Synapse?
    var parentNeuron: Neuron!
    func set(parent: Neuron) {
        parentNeuron = parent
    }
    
    
    func transport(_ signal: Signal) {
        if let synapse = synapse {
            if !signal.isStopped {
                synapse.transmit(signal: signal)
            } else {
                print("[NEURON] - Signal did finish on this neuron")
                parentNeuron.brain.delegate?.signalDidFinish(signal: signal)
            }
            //synapse.transmit(signal: signal)
        } else {
            signal.isStopped = true
            parentNeuron.brain.delegate?.signalDidFinish(signal: signal)
        }
    }
    
    
    func wire(to dendrite: Dendrite, with id: UInt) -> Synapse {
        let synapse = Synapse(transmitter: self, receiver: dendrite, id: id)
        self.synapse = synapse
        return synapse
    }
}
