//
//  Signal.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 09/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import Foundation
//dopamine, serotonin, norepinephrine and acetylcholine.
public class Signal {
    public enum SignalType: CaseIterable {
        case glutamate, norepinephrine, gaba, dopamine, serotonine, acetylcholine
    }
    var numberOfTransmissions: Int {
        get {
            points.count
        }
    }
    var isStopped: Bool = false
    public var maxTransmissions = 192
    var points = [Point]() {
        didSet {
            if points.count > maxTransmissions - 1 {
                isStopped = true
                completion(self)
            }
        }
    }
    let uuid: String
    let type: SignalType
    let completion: (Signal) -> ()
    public init(type: SignalType, completion: @escaping (Signal) -> ()) {
        self.type = type
        self.completion = completion
        uuid = UUID().uuidString
        //print("Signal allocated")
    }
    
    deinit {
//        print("[Signal] - number of transmissions: \(numberOfTransmissions)")
//        print("Signal deallocated")
    }
}
