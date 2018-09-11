//
//  MeowNetClient.swift
//  ARLandOne
//
//  Created by Su Yijia on 16/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import EthereumKit
import Alamofire

class MeowNetClient {
    
    public let dataEncoder = MeowCallDataEncoder()
    public let dataDecoder = MeowCallDataDecoder()

    private let geth = Geth(configuration: Configuration(
        network: MeowConfig.ETH.network,
        nodeEndpoint: MeowConfig.ETH.nodeEndpoint,
        etherscanAPIKey: MeowConfig.ETH.etherscanAPIKey
    ))
    
    func getBalance(wallet: MeowWallet, callback: @escaping (_ balance: Wei?) -> Void) {
        self.geth.getBalance(of: wallet.address) { (result: EthereumKit.Result<EthereumKit.Balance>) in
            switch result {
            case .success(let balance):
                
                log.verbose(balance)
                callback(balance.wei)
                
                break
            case .failure(let error):
                log.error(error)
                callback(nil)
            }
        }

    }
    
    func getUSDRate(callback: @escaping (_ usdRate: Double?) -> Void) {
        Alamofire.request("https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD").responseJSON { response in
            switch response.result {
            case .success(let JSON):
                
                let response = JSON as! NSDictionary
                let price = response.object(forKey: "USD") as! Double
                callback(price)
                
                break
            case .failure(let error):
                
                log.error(error)
            }
        }
    }

    func getCurrencyValue(wei: Wei, callback: @escaping (_ currencyValue: Double?) -> Void) {
        Alamofire.request("https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD").responseJSON { response in
            switch response.result {
            case .success(let JSON):
                
                let response = JSON as! NSDictionary
                let price = response.object(forKey: "USD") as! Double
                callback(price)
                
                break
            case .failure(let error):
                
                log.error(error)
            }
        }
    }
    
    func getTokenName(type: MeowTokenType, address: String, callback: @escaping (_ tokenName: String?) -> Void) -> Void {
        
        var callData : String!
        switch type {
        case .ERC20:
            callData = self.dataEncoder.callDataForERC20TokenName()
        case .ERC721:
            callData = self.dataEncoder.callDataForERC721TokenName()
        }
        
        self.geth.call(to: address, data: callData) { result in
            switch result {
            case .success(let returnData):
                if let tokenName = self.dataDecoder.stringFromCallData(returnData) {
                    if tokenName.count != 0 {
                        callback(tokenName)
                        log.debug("tokenName ---- " + tokenName)
                    }
                    else {
                        callback(nil)
                    }

                }
                else {
                    callback(nil)
                }
                break
            case .failure(let error):
                log.error(error)
                callback(nil)
            }
        }
    }
    

    func getTokenSymbol(type: MeowTokenType, address: String, callback: @escaping (_ tokenSymbol: String?) -> Void) -> Void {
        
        var callData : String!
        switch type {
        case .ERC20:
            callData = self.dataEncoder.callDataForERC20TokenSymbol()
        case .ERC721:
            callData = self.dataEncoder.callDataForERC721TokenSymbol()
        }
        
        self.geth.call(to: address, data: callData) { result in
            switch result {
            case .success(let returnData):
                if let tokenSymbol = self.dataDecoder.stringFromCallData(returnData) {
                    if tokenSymbol.count != 0 {
                        callback(tokenSymbol)
                        log.debug("tokenSymbol ---- " + tokenSymbol)
                    }
                    else {
                        callback(nil)
                    }
                }
                else {
                    callback(nil)
                }
                break
            case .failure(let error):
                log.error(error)
                callback(nil)
            }
        }
    }
    
    
    func getTokenBalance(type: MeowTokenType, wallet: MeowWallet, token: MeowToken, callback: @escaping (_ balance: Wei?) -> Void) {
        
        var callData : String!
        switch type {
        case .ERC20:
            callData = self.dataEncoder.callDataForERC20TokenBalanceOf(address: wallet.address)
        case .ERC721:
            callData = self.dataEncoder.callDataForERC721TokenBalanceOf(address: wallet.address)
        }
    
        log.debug(type.rawValue + " ---- getTokenBalance call data ---" + callData)
        self.geth.call(to: token.contractAddress, data: callData) { result in
            switch result {
            case .success(let returnData):
                log.debug("getTokenBalnce return raw data --- " + returnData)
                if let balance = self.dataDecoder.BIntFromCallData(returnData) {
                    log.debug("getTokenBalance return data --- " + balance.asString(withBase:10))
                    callback(balance)
                }
                else {
                    callback(nil)
                }
                break
            case .failure(let error):
                log.error(error)
                callback(nil)
            }
        }
    }
    
    func getERC20TokenDecimal(address: String, callback: @escaping (_ tokenDecimal: Int?) -> Void) -> Void {
        
        self.geth.call(to: address, data: self.dataEncoder.callDataForERC20TokenDecimals()) { result in
            switch result {
            case .success(let returnData):
                //                log.debug("get token decimal return data --- " + returnData)
                
                if let decimal = self.dataDecoder.intFromCallData(returnData) {
                    if decimal != 0 {
                        callback(decimal)
                    }
                    else {
                        callback(nil)
                    }
                }
                else {
                    callback(nil)
                }
            case .failure(let error):
                log.error(error)
                callback(nil)
            }
            
        }
    }
    
    func getERC721TokenOwnerOf(address: String, tokenId: Int, callback: @escaping (_ address: String?) -> Void) -> Void {
        
        self.geth.call(to: address, data: self.dataEncoder.callDataForERC721TokenOwnerOf(tokenId: tokenId)) { result in
            switch result {
            case .success(let returnData):
                log.debug("get getERC721TokenOwnerOf return data --- " + returnData)
                
                if returnData == "0x" {
                    callback(nil)
                }
                else {
                    callback(returnData)
                }
            case .failure(let error):
                log.error(error)
                callback(nil)
            }
            
        }

        
    }

    
    
    func sendTransaction(tx: MeowTransaction, callback: @escaping (_ txHash: String?) -> Void) {
        
        MeowManager.shared.signTransaction(tx: tx) { signTxString in
            
            guard let signTxString = signTxString else { return }
            
            log.debug("signed tx string!! ------ " + signTxString)
            // make transfer
            
            self.geth.sendRawTransaction(rawTransaction: signTxString) { result in
                switch result {
                case .success(let returnData):
                    
                    log.debug("tx success!! return data: " + returnData.id)
                    
                    // add nonce
                    var wallet = MeowManager.shared.wallet!
                    wallet.nonce = wallet.nonce + 1
                    
                    MeowManager.shared.updateWalletAndSync(wallet)
                    
                    callback(returnData.id)
                    
                    break
                case .failure(let error):
                    log.error(error)
                    callback(nil)
                }
            }

        }

    }
    
    func getTransactionHistory(wallet: MeowWallet, callback: @escaping (_ txs: [MeowTransactionHistory]?) -> Void) {
        self.geth.getTransactions(address: wallet.address) { result in
            switch result {
            case .success(let returnData):
                var returnTxs : [MeowTransactionHistory] = []
                returnData.elements.forEach({ tx in
                    let meowTx = MeowTransactionHistory.init(transaction: tx)
                    returnTxs.append(meowTx)
                })
                callback(returnTxs)
                break
            case .failure(let error):
                log.error(error)
                callback(nil)
            }
        }
    }
    
    func getNonce(wallet: MeowWallet, callback: @escaping (_ nonce: Int?) -> Void) {
        self.geth.getTransactionCount(of: wallet.address) { result in
            switch result {
            case .success(let returnData):
                callback(returnData)
                break
            case .failure(let error):
                log.error(error)
                callback(nil)
            }

        }
    }

}
