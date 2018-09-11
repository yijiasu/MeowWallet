//
//  MeowCallDataDecoder.swift
//  ARLandOne
//
//  Created by Su Yijia on 21/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import EthereumKit

class MeowCallDataDecoder {
    public func stringFromCallData(_ calldata: String) -> String? {
        let dataString = String(calldata.deletingPrefix("0x").dropFirst(128))
        if let data = Data.init(fromHexEncodedString: dataString) {
            if let returnStr = String.init(data: data, encoding: .utf8) {
                return returnStr
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    public func intFromCallData(_ calldata: String) -> Int? {
        
        let dataString = String(calldata.deletingPrefix("0x"))
        return Int(dataString, radix: 16)
        
    }
    
    public func BIntFromCallData(_ calldata: String) -> BInt? {
        let dataString = String(calldata.deletingPrefix("0x"))
        if dataString.count == 0 {
            return nil
        }
        else {
            let bint = BInt(number: dataString, withBase: 16)
            return bint
        }
    }
}
