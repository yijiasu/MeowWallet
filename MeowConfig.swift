//
//  MeowConfig.swift
//  ARLandOne
//
//  Created by Su Yijia on 11/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import EthereumKit
struct MeowConfig {
    struct UI {
        static let windowHeight = 340

    }
    struct KeyStore {
        
        static let keyStoreDir = FileManager.documentsDir() + "/keystore"
        static let keyStoreFilePath = FileManager.documentsDir() + "/keystore/key.dat"
        static let keyStoreAddressCacheFilePath = FileManager.documentsDir() + "/keystore/address"
        static let AESKey = "passwordpasswore"
        static let AESIV = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    }
    
    struct ETH {
        static let network = EthereumKit.Network.ropsten
        static let nodeEndpoint = "https://ropsten.infura.io/Sy6sWPsjVAAhlVFnsqnw"
        static let etherscanAPIKey = "8RV2NNZQBP9J6KI2Z4WZ21ANTCVI6GGB72"

    }
//    struct Realm {
//        static let dbPath = FileManager.documentsDir() + "/meow/database.realm"
//    }
}
