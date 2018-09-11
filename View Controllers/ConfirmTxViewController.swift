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
import PKHUD

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
        
        self.navigationItem.title = "Confirm Transaction"
        self.navigationItem.hidesBackButton = true
        
        
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
                row.value = EthereumKit.Converter.toEther(wei: tx.amount).decimalExpansion(precisionAfterComma: 6) + " ETH"
        }
            <<< LabelRow { row in
                row.title = "Gas Limit"
                row.value = String(tx.gasLimit)
        }
            <<< GasPriceRow { row in
                row.title = "Gas Price"
                row.value = tx.gasPrice
                }.onChange({ row in
                    self.tx.gasPrice = row.value!
                    self.form.allSections.first!.forEach { $0.updateCell() }
                })
            <<< LabelRow { row in
                row.title = "Max Fee"
                }.cellUpdate({ (cell, row) in
                    let txFeeInWei = BInt(EthereumKit.Converter.toWei(GWei: self.tx.gasPrice)) * BInt.init(self.tx.gasLimit)
                    row.value = EthereumKit.Converter.toEther(wei: txFeeInWei).decimalExpansion(precisionAfterComma: 6) + " ETH"
                })
            <<< LabelRow { row in
                row.title = "Max Total"
                }.cellUpdate({ (cell, row) in
                    let txFeeInWei = BInt(EthereumKit.Converter.toWei(GWei: self.tx.gasPrice)) * BInt.init(self.tx.gasLimit)
                    let totalInWei = txFeeInWei + self.tx.amount
                    row.value = EthereumKit.Converter.toEther(wei: totalInWei).decimalExpansion(precisionAfterComma: 6) + " ETH"
                })

        
        form +++ Section()
            <<< ButtonRow { row in
                row.title = "Submit"
                }.onCellSelection({ (_, _) in
                    
                    // set gas price
                    
                    HUD.show(.progress)
                    MeowManager.shared.netClient.sendTransaction(tx: self.tx, callback: { txHash in
                        HUD.flash(.labeledSuccess(title: "Success", subtitle: "Transaction sent"), delay: 1.0)
                        self.navigationController?.popToRootViewController(animated: true)
                        log.debug(txHash ?? "")
                    })
                })

            <<< ButtonRow { row in
                row.title = "Reject"
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = UIColor.red
                }).onCellSelection({ (cell, row) in
                    self.navigationController?.popViewController(animated: true)
                })

        
    }

}
