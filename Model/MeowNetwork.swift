//
//  MeowNetwork.swift
//  ARLandOne
//
//  Created by Su Yijia on 16/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation

struct MeowNetwork: Equatable {
    
    enum Kind: String {
        static let allValues = [main, ropsten, rinkeby, custom]
        case main = "main"
        case ropsten = "ropsten"
        case rinkeby = "rinkeby"
        case custom = "custom"
    }
    
    var kind: Kind
    var endpoint: String
}


