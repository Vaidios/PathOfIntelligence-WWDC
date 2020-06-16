//
//  Synapse.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 09/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import Foundation

public class Synapse {
    
    public let axon: Axon
    public let dendrite: Dendrite
    var synapticChain: SynapticChain? = nil
    var isLastSynapse = false
    let id: UInt
    
    func transmit(signal: Signal) {
        dendrite.forward(signal: signal)
    }
    init(transmitter axon: Axon, receiver dendrite: Dendrite, id: UInt) {
        self.axon = axon
        self.dendrite = dendrite
        self.id = id
        if let denriteSynapses = dendrite.synapses {
            if denriteSynapses.count > 0 {
                isLastSynapse = true
            }
        }
        dendrite.setSynapse(self)
    }
    
    func containts(uuid: String) -> Bool {
        return uuid == self.synapticChain?.uuid
    }
    
    func destroy() {
        axon.synapse = nil
        dendrite.synapses?.removeAll(where: { (synapse) -> Bool in
            if synapse.id == self.id {
                return true
            } else {
                return false
            }
        })
    }
}
