//
//  Wei+DisplayValue.swift
//  ARLandOne
//
//  Created by Su Yijia on 23/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import EthereumKit

extension Wei {
    
    func displayETHValue(precision: Int = 6) -> String {
        return EthereumKit.Converter.toEther(wei: self).decimalExpansion(precisionAfterComma: precision) + " ETH"
    }
    
}

extension Converter {
    
    public static func toGWei(wei: Wei) -> BDouble {
        return BDouble(wei.asString(withBase: 10), radix: 10)! / BDouble(1000000000)
    }

    
}
