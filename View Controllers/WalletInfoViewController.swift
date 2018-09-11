//
//  WalletInfoViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 13/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Eureka
import PKHUD

class WalletInfoViewController: FormViewController {
    
    public var wallet: MeowWallet!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wallet = MeowManager.shared.wallet
        self.navigationItem.title = "Info"

        
        form +++ Section(header: "Wallet Name", footer: "This name will be only stored locally")
            <<< TextRow { (row: TextRow) in
                row.value = wallet?.name
                row.placeholder = wallet?.fallbackName
                row.cell.titleLabel?.removeFromSuperview()
            }.onCellHighlightChanged({ (cell, row) in
                if !row.isHighlighted {
                    
                    self.wallet?.name = row.value
                    MeowManager.shared.updateWalletAndSync(self.wallet!)
                    
                }
            })

        form +++ Section(header: "Address", footer: "")
            <<< LabelRow { (row: LabelRow) in
                row.title = self.wallet!.address
                row.cell.detailTextLabel?.removeFromSuperview()
            }
            <<< LeftAlignedButtonRow { row in
                row.title = "Copy to Clipboard"
                }.onCellSelection { (_, _) in
                    MeowUtil.copyToClipboard(self.wallet!.address)
                    HUD.flash(.label("Copied!"), delay: 0.8)
            }
            <<< LeftAlignedButtonRow { row in
                row.title = "View on Etherscan"
            }.onCellSelection({ (_, _) in
                MeowUtil.viewWalletInEtherscan(self.wallet!)
            })
    }


}
