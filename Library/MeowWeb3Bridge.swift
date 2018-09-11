//
//  MeowWeb3Bridge.swift
//  ARLandOne
//
//  Created by Su Yijia on 20/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import UIKit
import Erik

class MeowWeb3Bridge  {
    
    init() {
        if let engine = Erik.sharedInstance.layoutEngine as? WebKitLayoutEngine {
            engine.javaScriptQueue = .main
//            engine.waitLoadingQueue = .main
            engine.callBackQueue = .main
            //engine.callBackQueue = .main // maybe this one also if you access some attribute in callback like title
        }

        let browser = Erik.visit(url: URL.init(string: "http://localhost:9898/web3.html")!) { (doc, err) in
            Erik.evaluate(javaScript: "1+1", completionHandler: { (obj, err) in
                log.verbose(obj)
            })
        }
    }
}
