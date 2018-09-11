//
// Created by Su Yijia on 12/5/2018.
// Copyright (c) 2018 Su Yijia. All rights reserved.
//

import Foundation
import RealmSwift
import EthereumKit

//public typealias BInt = EthereumKit.BInt
//public typealias BDouble = EthereumKit.BDouble


struct MeowWallet: Equatable {
    
//    Wei = 10^0 Wei
//    Ada = 10^3 Wei
//    Babbage = 10^6 Wei
//    Shannon = 10^9 Wei
//    Szabo = 10^12 Wei
//    Finney = 10^15 Wei
//    Ether = 10^18 Wei

    var name: String?
    var address: String
    var balanceInWei: Wei?
    var currencyBalance: Double?
    var nonce: Int = 0
    var tokens: [MeowToken] = []
    var fallbackName: String {
        get {
                return "Account \(self.address.prefix(6))"
            }
    }
    

    var displayName: String {
        get {
            return self.name ?? self.fallbackName
        }
    }

    var ether: Ether? {
        get {
            if let wei = balanceInWei {
                return EthereumKit.Converter.toEther(wei: wei)
//                return BDouble(wei.asString(radix: 10), radix: 10)! / BDouble(pow(Double(10), Double(18)))
            }
            else {
                return nil
            }
        }
    }
    
    //name: nil, address: keystore.defaultETHAddress()!, balanceInWei: nil, currencyBalance: nil, tokens: []
    init(name: String?, address: String) {
        self.name = name
        self.address = address
    }
    

}

final class MeowWalletObject: Object {
    
    @objc dynamic var address: String = ""
    @objc dynamic var name: String? = ""
    @objc dynamic var balanceInWei: String? = ""
    @objc dynamic var nonce: Int = 5

    let currencyBalance = RealmOptional<Double>()
    
    
    let tokens = List<MeowTokenObject>()
    
    override class func primaryKey() -> String? {
        return "address"
    }
}


func == (lhs: MeowWallet, rhs: MeowWallet) -> Bool {
    return lhs.address == rhs.address
}

extension MeowWallet: MeowPersistable {
    
    // From Realm Object to Struct
    init(managedObject: MeowWalletObject) {
        
        self.name = managedObject.name
        self.address = managedObject.address
        self.balanceInWei =  managedObject.balanceInWei != nil ? BInt.init(managedObject.balanceInWei!, radix: 10) : nil
        self.currencyBalance = managedObject.currencyBalance.value
        self.nonce = managedObject.nonce
        self.tokens = managedObject.tokens.map({ (tokenObject) -> MeowToken in
//            let meowToken = MeowToken(contractAddress: tokenObject.contractAddress,
//                                      symbol: tokenObject.symbol,
//                                      type: MeowTokenType(rawValue: tokenObject.type)!,
//                                      decimal: tokenObject.decimal,
//                                      balanceInWei: tokenObject.balanceInWei
//                                      )
            let meowToken = MeowToken.init(managedObject: tokenObject)
            return meowToken
        })
        
    }
    
    func managedObject() -> MeowWalletObject {
        
        let obj = MeowWalletObject()
        
        obj.name = self.name
        obj.address = self.address
        obj.balanceInWei = self.balanceInWei != nil ? self.balanceInWei!.asString(withBase: 10) : nil
        obj.currencyBalance.value = self.currencyBalance
        obj.nonce = self.nonce
        
        self.tokens.forEach { (token) in
            
//            let tokenObj = MeowTokenObject()
//
//            tokenObj.contractAddress = token.contractAddress
//            tokenObj.symbol = token.symbol
//            tokenObj.decimal = token.decimal
//            tokenObj.type = token.type.rawValue
//            tokenObj.balanceInWei = token.balanceInWei ?? 0
            
            let tokenObj = token.managedObject()
            
            obj.tokens.append(tokenObj)
        }
        
        return obj
        
        
    }
}
