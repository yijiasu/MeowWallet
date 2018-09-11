//
//  MeowUtil.swift
//  ARLandOne
//
//  Created by Su Yijia on 11/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import Alertift

final class MeowUtil {
    
    static func alert(message: String) {
        Alertift.alert(title: message, message: nil).action(.default("OK")).show()
    }
    
    static func alert(message: String, title: String) {
        Alertift.alert(title: title, message: message).action(.default("OK")).show()
    }
    
    static func confirm(message: String, callback: @escaping (() -> Void)) {
        Alertift.alert(title: message, message: nil)
            .action(.cancel("Cancel"))
            .action(.default("OK")) { (_, _, _) in
                callback()
        }.show()
    }

    static func askForInput(title: String, callback: @escaping (_ input: String?) -> Void) {
        Alertift.alert(title: title, message: nil)
            .textField { textField in textField.placeholder = "JSON-RPC URL" }
            .action(.cancel("Cancel"), handler: { (_, _, _) in
                callback(nil)
            })
            .action(.default("OK"), handler: { (_, _, fields: [UITextField]?) in

            guard let input = fields?.first?.text else { callback(nil); return; }
            callback(input)
            
         })
        .show()
    }
    
    static func verifyETHAddress(address: String) -> Bool {
        let regex = "^0x[a-fA-F0-9]{40}$"
        return address.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    static func displayDate(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: date)

    }
    
    static func viewTransactionInEtherscan(_ tx: MeowTransactionHistory) {
        self.viewTransactionInEtherscan(txHash: tx.txHash)
    }
    
    static func viewWalletInEtherscan(_ wallet: MeowWallet) {
        self.viewWalletInEtherscan(walletAddress: wallet.address)
    }
    
    static func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }

    private static func viewTransactionInEtherscan(txHash: String) {
        
        switch MeowConfig.ETH.network {
        case .ropsten:
            let url = URL.init(string: "https://ropsten.etherscan.io/tx/\(txHash)")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        default: break
        }
    }
    
    private static func viewWalletInEtherscan(walletAddress: String) {
        
        switch MeowConfig.ETH.network {
        case .ropsten:
            let url = URL.init(string: "https://ropsten.etherscan.io/address/\(walletAddress)")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        default: break
        }
    }
    
    


}
