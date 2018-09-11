//
//  MeowCurrencyConverter.swift
//  ARLandOne
//
//  Created by Su Yijia on 23/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import EthereumKit

class MeowCurrencyConverter {
    
    private var usdRate : Double?
    private let netClient = MeowNetClient()
    
    // TODO: Enable auto-refresh
    
    init() {
        
        // fetch usd rate from api
        self.netClient.getUSDRate { usdRate in
            
            guard let rate = usdRate else { return }
            self.usdRate = rate
            
        }
        
    }
    
    func convertToUSD(from wei: Wei) -> Double? {
        return convertToUSD(from: Converter.toEther(wei: wei))
    }
    
    func convertToUSDInString(from wei: Wei) -> String? {
        
        guard let usdValue = self.convertToUSD(from: wei) else { return nil }
        return String(usdValue) + " USD"
        
    }

    func convertToUSD(from ether: Ether) -> Double? {
        
        guard let rate = self.usdRate else { return nil }
        guard let value = Double(ether.decimalExpansion(precisionAfterComma: 8)) else { return nil }

        return Double(round( rate * value  * 100 ) / 100)
    }
    
    func convertToUSDInString(from ether: Ether) -> String? {
        
        guard let usdValue = self.convertToUSD(from: ether) else { return nil }
        return String(usdValue) + " USD"
        
    }
    

}
