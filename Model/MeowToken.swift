//
//  MeowToken.swift
//  ARLandOne
//
//  Created by Su Yijia on 16/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import RealmSwift
import EthereumKit

enum MeowTokenType: String {
    case ERC20 = "ERC-20"
    case ERC721 = "ERC-721"
}

struct MeowToken: Equatable {
    
    var contractAddress: String
    var symbol: String
    var type: MeowTokenType
    var decimal: Int
    var balanceInWei: Wei?
    var balance: BDouble?  {
        get {
            guard let uBalanceInWei = balanceInWei else { return nil }
            switch type {
            case .ERC20:
                return BDouble(uBalanceInWei.asString(withBase: 10), radix: 10)! / BDouble(pow(Double(10), Double(decimal)))
            case .ERC721:
                return BDouble(uBalanceInWei.asString(withBase: 10), radix: 10)!
            }
        }
    }
    
    
    init(contractAddress: String, symbol: String, type: MeowTokenType, decimal: Int, balanceInWei: Wei? = nil) {
        self.contractAddress = contractAddress
        self.symbol = symbol
        self.type = type
        self.decimal = decimal
        self.balanceInWei = balanceInWei
    }
    
}

func == (lhs: MeowToken, rhs: MeowToken) -> Bool {
    return lhs.contractAddress == rhs.contractAddress
}

final class MeowTokenObject: Object {
    
    @objc dynamic var contractAddress = ""
    @objc dynamic var symbol = ""
    @objc dynamic var type = ""
    @objc dynamic var decimal = 0
    @objc dynamic var balanceInWei: String? = ""
    
    override class func primaryKey() -> String? {
        return "contractAddress"
    }

}


extension MeowToken: MeowPersistable {
    
    init(managedObject: MeowTokenObject) {
        
        self.contractAddress = managedObject.contractAddress
        self.symbol = managedObject.symbol
        self.type = MeowTokenType.init(rawValue: managedObject.type)!
        self.decimal = managedObject.decimal
        self.balanceInWei = managedObject.balanceInWei != nil ? Wei.init(managedObject.balanceInWei!, radix: 10) : nil
        
    }
    
    func managedObject() -> MeowTokenObject {
        
        let obj = MeowTokenObject()
        
        obj.contractAddress = self.contractAddress
        obj.symbol = self.symbol
        obj.type = self.type.rawValue
        obj.decimal = self.decimal
        obj.balanceInWei = self.balanceInWei?.asString(withBase: 10)
        
        return obj
    }
}
