//
//  BackupWalletViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 15/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Eureka
import PKHUD

class BackupWalletViewController: FormViewController {

    var buttonRow : LeftAlignedButtonRow!
    var mnemonicString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Backup"
        self.buttonRow = LeftAlignedButtonRow { row in
            row.title = "Backup Wallet"
            }.onCellSelection({ (_, _) in
                MeowUtil.confirm(message: "Do not recover your seed words in a public place! These words can be used to steal all your accounts!", callback: {
                    UIView.performWithoutAnimation {
                        self.showMnemonics()
                    }
                })
            })
        
        form +++ Section() <<< self.buttonRow
    }
    
    func showMnemonics() {
        
        // show words
        form.remove(at: 0)
        
        let wordSection = Section()
        
        let wordRow = LabelRow { row in
            
            let mnemonicString = try? MeowManager.shared.keystore.getMnemonicString()

            row.title = mnemonicString
            self.mnemonicString = mnemonicString
            row.cell.textLabel?.numberOfLines = 0
            row.cell.height = {
                return 120
            }
            
        }
        
        wordSection <<< wordRow
        form +++ wordSection
        
        let btnSection = Section()
        
        let btnRow = LeftAlignedButtonRow { row in
            row.title = "Copy to Clipboard"
            }.onCellSelection { (_, _) in
                if let word = self.mnemonicString {
                    MeowUtil.copyToClipboard(word)
                    HUD.flash(.label("Copied!"), delay: 0.8)
                }
        }
        
        btnSection <<< btnRow
        form +++ btnSection

        
    }

    
}
