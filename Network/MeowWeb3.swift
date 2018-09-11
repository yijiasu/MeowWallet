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

        let web3Code = try! String.init(contentsOf: Bundle.main.url(forResource: "web3-light.min", withExtension: "js", subdirectory: "EmbedJS")!)
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


    }
    
    func getWeb3Version() {
        
        if let version = self.context.evaluateScript("web3.version.api") {
            log.debug("Web3 version is \(version)")
        }

    }
    
    func getTokenName(address: String) {
        let contractABI = try! String.init(contentsOf: Bundle.main.url(forResource: "erc20.abi", withExtension: "json", subdirectory: "EmbedJS")!)
//        log.debug(contractABI)
        self.context.evaluateScript("var abi = " + contractABI)
//
        self.context.evaluateScript("var tokenContract = web3.eth.contract(abi).at('\(address)')")
        if let callData = self.context.evaluateScript("tokenContract.name.getData()") {
            log.debug(("CallData is \(callData)"))
        }
//
        
    }
    
//    func getCallData(funcProto: String, params: [String]) -> String {
//
//    }
}
