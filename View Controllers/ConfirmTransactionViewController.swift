//
//  ConfirmTransactionViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 22/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import Eureka
import EthereumKit

class ConfirmTxViewController : FormViewController {
    
    private var wallet: MeowWallet!
    private var tx : MeowTransaction!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(transaction: MeowTransaction) {
        self.tx = transaction
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.wallet = MeowManager.shared.wallet!
        
        self.navigationItem.title = "Confirm"
        
        form +++ Section.init("Transaction")
            <<< LabelRow { row in
                row.title = "From"
                row.value = self.wallet.address
        }
            <<< LabelRow { row in
                row.title = "To"
                row.value = tx.to
        }
            <<< LabelRow { row in
                row.title = "Amount"
                row.value = EthereumKit.Converter.toEther(wei: tx.amount).decimalExpansion(precisionAfterComma: 4) + " ETH"
        }
            <<< LabelRow { row in
                row.title = "Gas Limit"
                row.value = String(tx.gasLimit)
        }
            <<< LabelRow { row in
                row.title = "Gas Price"
                row.value = String(tx.gasPrice) + " GWei"
        }
            <<< LabelRow { row in
                let txFeeInWei = BInt(EthereumKit.Converter.toWei(GWei: tx.gasPrice)) * BInt.init(tx.gasLimit)
                row.title = "Fee"
                row.value = EthereumKit.Converter.toEther(wei: txFeeInWei).decimalExpansion(precisionAfterComma: 4) + " ETH"
        }
        
        
        form +++ Section()
            <<< ButtonRow { row in
                row.title = "Submit"
        }


        
    }

}
