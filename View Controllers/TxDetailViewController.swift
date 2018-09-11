//
//  TxDetailViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 24/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import Eureka
import EthereumKit

class TxDetailViewController : FormViewController {
    
//    var txHash: String
//    var from: String
//    var to: String
//    var amount: Wei
//    var gasPrice: Int
//    var gasUsed: Int       // Only IN Tx History
//    var time: Date

    private var tx: MeowTransactionHistory!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(transactionHistory: MeowTransactionHistory) {
        self.tx = transactionHistory
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Details"

        let section = Section()
        
        section <<< LabelRow { row in
            row.title = "Tx Hash"
            row.value = tx.txHash
        }
        
        switch tx.direction(hostAddress: MeowManager.shared.wallet!.address) {
            
        case .received:
            section <<< LabelRow { row in
                row.title = "From"
                row.value = tx.from
            }
            break
        case .sent:
            section <<< LabelRow { row in
                row.title = "To"
                row.value = tx.to
            }
        }
        
        section <<< LabelRow { row in
            row.title = "Amount"
            row.value = tx.amount.displayETHValue()
        }
        
        section <<< LabelRow { row in
            row.title = "Gas Price"
            row.value = Converter.toGWei(wei: Wei(tx.gasPrice)).decimalDescription + " GWei"
        }
        
        section <<< LabelRow { row in
            row.title = "Gas Used"
            row.value = String(tx.gasUsed)
        }

        section <<< LabelRow { row in
            row.title = "Date"
            row.value = MeowUtil.displayDate(tx.time)
        }
        
        form +++ section
        
        // Button Section
        
        let buttonSection = Section()
        
        buttonSection <<< LeftAlignedButtonRow { row in
            row.title = "View on Etherscan"
            }.onCellSelection({ (_, _) in
                MeowUtil.viewTransactionInEtherscan(self.tx!)
            })

        form +++ buttonSection

        
    }
    
}
