//
//  MeowJSBridge.swift
//  ARLandOne
//
//  Created by Su Yijia on 19/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import JavaScriptCore

class MeowCallDataEncoder {
    
    private let vm = JSVirtualMachine()
    private let context: JSContext

    init() {
        
        
        self.context = JSContext(virtualMachine: self.vm)

        let web3Code = try! String.init(contentsOf: Bundle.main.url(forResource: "web3", withExtension: "js", subdirectory: "EmbedJS")!)
        let cryptoCode = try! String.init(contentsOf: Bundle.main.url(forResource: "crypto-js", withExtension: "js", subdirectory: "EmbedJS")!)
        let bigNumberCode = try! String.init(contentsOf: Bundle.main.url(forResource: "bignumber.min", withExtension: "js", subdirectory: "EmbedJS")!)
        
        self.context.evaluateScript(bigNumberCode)
        self.context.evaluateScript(cryptoCode)
        self.context.evaluateScript(web3Code)
        self.context.evaluateScript("var Web3 = require('web3'); var web3 = new Web3();")
        
        self.context.exceptionHandler = { (ctx: JSContext!, value: JSValue!) in
            // type of String
            let stacktrace = value.objectForKeyedSubscript("stack").toString()
            // type of Number
            let lineNumber = value.objectForKeyedSubscript("line")
            // type of Number
            let column = value.objectForKeyedSubscript("column")
            let moreInfo = "in method \(String(describing: stacktrace))Line number in file: \(String(describing: lineNumber)), column: \(String(describing: column))"
            log.error("JS ERROR: \(value) \(moreInfo)")
        }
        
        let erc20ABI = try! String.init(contentsOf: Bundle.main.url(forResource: "erc20.abi", withExtension: "js", subdirectory: "EmbedJS")!)
        let erc721ABI = try! String.init(contentsOf: Bundle.main.url(forResource: "erc721.abi", withExtension: "js", subdirectory: "EmbedJS")!)

        self.context.evaluateScript(erc20ABI)
        self.context.evaluateScript(erc721ABI)

        self.context.evaluateScript("var erc20_contract = web3.eth.contract(erc20_abi).at('0x0')")
        self.context.evaluateScript("var erc721_contract = web3.eth.contract(erc721_abi).at('0x0')")



    }
    
    func getWeb3Version() {
        
        if let version = self.context.evaluateScript("web3.version.api") {
            log.debug("Web3 version is \(version)")
        }

    }
    
    private func callDataForERC20(funcName: String, params: [String] = []) -> String? {
        
        var paramSegment = params.joined(separator: "\",\"")
        paramSegment = "\"" + paramSegment + "\""
        
        if params.count == 0 {
            paramSegment = ""
        }
        
        let script = "erc20_contract.\(funcName).getData(\(paramSegment))"
        log.debug("executing js script ---" + script)
        if let callData = self.context.evaluateScript(script) {
            log.debug(("CallData is \(callData)"))
            return callData.toString()
        }
        else {
            return nil
        }

    }
    
    
    private func callDataForERC721(funcName: String, params: [String] = []) -> String? {
        
        var paramSegment = params.joined(separator: "\",\"")
        paramSegment = "\"" + paramSegment + "\""
        
        if params.count == 0 {
            paramSegment = ""
        }
        
        let script = "erc721_contract.\(funcName).getData(\(paramSegment))"
        log.debug("executing js script ---" + script)
        if let callData = self.context.evaluateScript(script) {
            log.debug(("CallData is \(callData)"))
            return callData.toString()
        }
        else {
            return nil
        }
        
    }
    
    private func callDataForERC721(funcName: String, params: Int) -> String? {
        
        
        let script = "erc721_contract.\(funcName).getData(\(String(params)))"
        log.debug("executing js script ---" + script)
        if let callData = self.context.evaluateScript(script) {
            log.debug(("CallData is \(callData)"))
            return callData.toString()
        }
        else {
            return nil
        }
        
    }


    
    // ERC-20
    
    func callDataForERC20TokenName() -> String {
        return self.callDataForERC20(funcName: "name")!
    }
    
    func callDataForERC20TokenSymbol() -> String {
        return self.callDataForERC20(funcName: "symbol")!
    }
    
    func callDataForERC20TokenDecimals() -> String {
        return self.callDataForERC20(funcName: "decimals")!
    }

    func callDataForERC20TokenBalanceOf(address: String) -> String {
        return self.callDataForERC20(funcName: "balanceOf", params: [address])!
    }

    // ERC-721
    
    func callDataForERC721TokenName() -> String {
        return self.callDataForERC721(funcName: "name")!
    }
    
    func callDataForERC721TokenSymbol() -> String {
        return self.callDataForERC721(funcName: "symbol")!
    }
    
    func callDataForERC721TokenOwnerOf(tokenId: Int) -> String {
        return self.callDataForERC721(funcName: "ownerOf", params: tokenId)!
    }
    
    func callDataForERC721TokenBalanceOf(address: String) -> String {
        return self.callDataForERC721(funcName: "balanceOf", params: [address])!
    }


}
