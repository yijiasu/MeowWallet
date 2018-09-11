//
//  WalletSettingViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 13/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Eureka
class WalletSettingViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Setting"
        form +++ Section("Security")
            <<< LabelRow { (row : LabelRow) in
                row.title = "Auto Lock"
                row.cell.selectionStyle = .default
                row.cell.accessoryType = .disclosureIndicator
                
                }.onCellSelection({ (_, _) in
                    self.navigationController?.pushViewController(AutoLockSettingViewController(), animated: true)
                })

        
        //        form +++ Section(header: "Network", footer: "")
//            <<< PushRow<MeowNetwork.Kind> { (row: PushRow) in
//                row.title = "Ethereum Network"
//                row.options = MeowNetwork.Kind.allValues
//                row.onPresent { (controller: FormViewController, controller2: SelectorViewController<SelectorRow<PushSelectorCell<MeowNetwork.Kind>>>) in
//                    controller2.dismissOnSelection = false
//                    controller2.dismissOnChange = false
//
//                }.onChange { (row: PushRow<MeowNetwork.Kind>) in
//                    if row.value! == .custom {
//                        MeowUtil.askForInput(title: "Custom URL") { input in
//                            if let url = input {
//                                log.info(url)
//                            }
//                            else {
//                                row.value = .main
//                                row.reload()
//                            }
//                        }
//                    }
//                }
//
//
//        }
//            <<< WalletNetworkSelectorRow { (row: WalletNetworkSelectorRow) in row.value = MeowNetwork(kind: .main, endpoint: "123") }
//            <<< LabelRow { (row : LabelRow) in row.title = "Ethereum Network" }
        
        
        let backupWalletRow = LabelRow { (row : LabelRow) in
            row.title = "Backup Wallet"
            row.cell.selectionStyle = .default
            row.cell.accessoryType = .disclosureIndicator

            }.onCellSelection({ (_, _) in
                let nextVC = BackupWalletViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
            })

        
        let exportPrivateKeyRow = LabelRow { (row : LabelRow) in
            row.title = "Export Private Key"
            row.cell.selectionStyle = .default
            row.cell.accessoryType = .disclosureIndicator
            
            }.onCellSelection({ (_, _) in
                let nextVC = ExportPrivateKeyViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
            })

        form +++ Section(header: "Wallet", footer: "")
                <<< LabelRow { (row : LabelRow) in row.title = "Change Passcode" }
            <<< backupWalletRow
            <<< exportPrivateKeyRow


        form +++ Section()
                <<< ButtonRow { (row : ButtonRow) in row.title = "Lock" }
                    .onCellSelection({ (_, _) in
                        MeowManager.shared.lock()
                    })

        form +++ Section(footer: "Meow Wallet - Build 23")



    }


}
