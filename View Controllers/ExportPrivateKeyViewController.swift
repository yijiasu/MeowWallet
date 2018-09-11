//
//  ExportPrivateKeyViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 15/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Eureka
import PKHUD

class ExportPrivateKeyViewController: FormViewController {

    var buttonRow : LeftAlignedButtonRow!
    var privateKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.navigationItem.title = "Private Key"
        self.buttonRow = LeftAlignedButtonRow { row in
            row.title = "Export Private Key"
            }.onCellSelection({ (_, _) in
                MeowUtil.confirm(message: "Export private keys at your own risk!", callback: {
                    UIView.performWithoutAnimation {
                        self.showPrivateKey()
                    }
                })
            })
        
        form +++ Section() <<< self.buttonRow

    }
        
    
    func showPrivateKey() {
        
        // show words
        form.remove(at: 0)
        
        let wordSection = Section()
        
        let wordRow = LabelRow { row in
            
            let privateKey = try? MeowManager.shared.keystore.dumpPrivateKey()
            
            row.title = privateKey
            self.privateKey = privateKey
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
                if let key = self.privateKey {
                    MeowUtil.copyToClipboard(key)
                    HUD.flash(.label("Copied!"), delay: 0.8)
                }
        }
        
        btnSection <<< btnRow
        form +++ btnSection
        
        
    }

}
