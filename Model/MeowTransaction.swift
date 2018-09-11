//
//  MeowTransaction.swift
//  ARLandOne
//
//  Created by Su Yijia on 22/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import RealmSwift
import EthereumKit


// Tx by User
struct MeowTransaction {
    
    var from: String
    var to: String
    var amount: Wei
    var gasLimit: Int
    var gasPrice: Int
    var data: Data?
    
    func toRawTransaction(nonce: Int) -> RawTransaction {
        
        // TODO: convert data property
        let rawTx = RawTransaction.init(value: self.amount,
                                        to: Address.init(string: self.to),
                                        gasPrice: Converter.toWei(GWei: self.gasPrice) ,
                                        gasLimit: self.gasLimit,
                                        nonce: nonce)
        
        return rawTx
    }
    
    func toTransactionHistory(txHash: String) -> MeowTransactionHistory {
        return MeowTransactionHistory.init(txHash: txHash, from: self.from, to: self.to, amount: self.amount, gasPrice: self.gasPrice, time: Date.init())
    }
    
}

// Tx From API
struct MeowTransactionHistory : Equatable {
    
    enum TransactionDirection {
        case received
        case sent
    }
    
    var txHash: String
    var from: String
    var to: String
    var amount: Wei
    var gasPrice: Int
    var gasUsed: Int       // Only IN Tx History
    var time: Date
    
    
    init(txHash: String, from: String, to: String, amount: Wei, gasPrice: Int, time: Date) {
        
        self.txHash = txHash
        self.from = from
        self.to = to
        self.amount = amount
        self.gasUsed = 0
        self.gasPrice = gasPrice
        self.time = time
        
    }
    
    init(transaction: EthereumKit.Transaction) {
        
        self.txHash = transaction.hash
        self.from = transaction.from
        self.to = transaction.to
        self.amount = Wei.init(transaction.value, radix: 10) ?? Wei.init(0)
        self.gasPrice = Int(transaction.gasPrice) ?? 0
        self.gasUsed = Int(transaction.gasUsed) ?? 0
        self.time =  Date.init(timeIntervalSince1970: TimeInterval(Int(transaction.timeStamp) ?? 0))
        
    }
    
    func direction(hostAddress: String) -> TransactionDirection {
        if self.from.lowercased() == hostAddress.lowercased() {
            return .sent
        }
        else {
            return .received
        }
    }
}

func == (lhs: MeowTransactionHistory, rhs: MeowTransactionHistory) -> Bool {
    return lhs.txHash == rhs.txHash
}


final class MeowTransactionHistoryObject: Object {
    

    @objc dynamic var txHash: String = ""
    @objc dynamic var from: String = ""
    @objc dynamic var to: String = ""
    @objc dynamic var amount: String = ""
    @objc dynamic var gasPrice: Int = 0
    @objc dynamic var gasUsed: Int = 0
    @objc dynamic var time: Date = Date()

    override class func primaryKey() -> String? {
        return "txHash"
    }

}

extension MeowTransactionHistory: MeowPersistable {
    
    init(managedObject: MeowTransactionHistoryObject) {
        
        self.txHash = managedObject.txHash
        self.from = managedObject.from
        self.to = managedObject.to
        self.amount = Wei.init(managedObject.amount, radix: 10) ?? Wei.init(0)
        self.gasPrice = managedObject.gasPrice
        self.gasUsed = managedObject.gasUsed
        self.time = managedObject.time
    }
    
    func managedObject() -> MeowTransactionHistoryObject {
        
        let obj = MeowTransactionHistoryObject()
        
        obj.txHash = self.txHash
        obj.from = self.from
        obj.to = self.to
        obj.amount = self.amount.asString(withBase: 10)
        obj.gasPrice = self.gasPrice
        obj.gasUsed = self.gasUsed
        obj.time = self.time
        
        return obj

    }

}

