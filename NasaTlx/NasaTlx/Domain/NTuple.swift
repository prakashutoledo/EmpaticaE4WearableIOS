//
//  NTuple.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/7/22.
//

import SwiftUI

public class Triple<X, Y, Z> {
    public let x: X
    public let y: Y
    public let z: Z
    
    init(x: X, y: Y, z: Z) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public class Pair<X, Y> {
    public let x: X
    public let y: Y
    
    init(x: X, y: Y) {
        self.x = x
        self.y = y
    }
}
