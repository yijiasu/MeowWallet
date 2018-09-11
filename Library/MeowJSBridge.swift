//
//  MeowJSBridge.swift
//  ARLandOne
//
//  Created by Su Yijia on 19/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import JavaScriptCore

class MeowWeb3 {
    
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
        context.evaluateScript("var Web3 = require('web3'); var web3 = new Web3();")


    }
    
    func getWeb3Version() {
        
        if let version = self.context.evaluateScript("web3.version.api") {
            log.debug("Web3 version is \(version)")
        }

    }
    
//    func getCallData(funcProto: String, params: [String]) -> String {
//
//    }
}
