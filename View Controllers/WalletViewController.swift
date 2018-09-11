//
//  WalletViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 11/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Eureka

class WalletViewController: FormViewController, AddTokenViewControllerDelegate {

    @IBOutlet weak var ethAddress: UILabel!
    private let keystore = MeowKeyStore.shared
    private var wallet: MeowWallet?
    private var lastTx : MeowTransactionHistory?
    
    func setupNavigationItem() {
        
        self.navigationItem.title = "Wallet"
        
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        let settingButton = UIBarButtonItem(title: "Setting", style: .plain, target: self, action: #selector(setting))
        
        self.navigationItem.leftBarButtonItems = [closeButton]
        self.navigationItem.rightBarButtonItems = [settingButton]

    }
    
    func onShowWalletInfoViewController() {
        self.navigationController?.pushViewController(WalletInfoViewController(), animated: true)
    }
    
    func onShowSendEtherViewController() {
        self.navigationController?.pushViewController(SendEtherViewController(), animated: true)
    }
    
    func onShowReceiveEtherViewController() {
        self.navigationController?.pushViewController(ReceiveEtherViewController(), animated: true)
    }
    
    func onShowWalletSettingViewController() {
        self.navigationController?.pushViewController(WalletSettingViewController(), animated: true)
    }
    


    
    func setupWalletInfoSession() {
        
        // ----- walletInfoSession ------
        
        let walletInfoSession = Section()
        walletInfoSession.tag = "walletInfoSession"
        
        let infoRow = WalletAccountInfoRow { row in row.value = self.wallet }
            .onCellSelection { cell, row in
                self.onShowWalletInfoViewController()
            }.cellUpdate({ (cell, row) in
                row.value = self.wallet
                row.update()
            })
        
        let actionRow = WalletAccountActionRow() { row in
            row.cell.onSend = { self.onShowSendEtherViewController() }
            row.cell.onReceive = { self.onShowReceiveEtherViewController() }
        }
        
        
        walletInfoSession <<< infoRow <<< actionRow
        
        form +++ walletInfoSession

    }
    
    func setupTransactionSession() {
        
        // ----- Last Transaction ------
        
        let txSession = Section(header: "Last Transaction", footer: "")
            <<< LabelRow { (row: LabelRow) in
                row.cell.selectionStyle = .default
                row.cell.accessoryType = .disclosureIndicator
                }.cellUpdate{ (cell, row) in
                    if let lastTx = self.lastTx {
                        switch lastTx.direction(hostAddress: self.wallet!.address) {
                        case .received:
                            row.title = "Received \(lastTx.amount.displayETHValue(precision: 2)) from \(lastTx.from)"
                            break
                        case .sent:
                            row.title = "Sent \(lastTx.amount.displayETHValue(precision: 2)) to \(lastTx.to)"
                        }
                    }
                }.onCellSelection({ (_, _) in
                    self.navigationController?.pushViewController(TxDetailViewController.init(transactionHistory: self.lastTx!), animated: true)
                })
            <<< LeftAlignedButtonRow { row in
                row.cellStyle = .default
                row.title = "View All"
                }.onCellSelection({ (_, _) in
                    self.navigationController?.pushViewController(TxListViewController(), animated: true)
                })
        
        txSession.tag = "txSession"

        txSession.hidden = Condition.function([], { form -> Bool in
            return !(self.lastTx != nil)
        })
        
        form +++ txSession
        
    }
    
    func deleteToken(_ token: MeowToken) {
        
        let tokenIndex = MeowManager.shared.wallet!.tokens.index { aToken -> Bool in
            return token == aToken
        }
        if let index = tokenIndex {
            MeowManager.shared.wallet!.tokens.remove(at: index)
        }
        
        self.wallet = MeowManager.shared.wallet!

        // remove from db
        
        let realm = MeowDatabase.realm
        if let managedObject = realm.objects(MeowToken.ManagedObject.self).filter("contractAddress = '\(token.contractAddress)'").first {
            let transaction = WriteTransaction(realm: realm)
            try? realm.write {
                realm.delete(managedObject)
            }
            
        }
        
        
    }
    
    func setupTokenSession() {

        
        let tokenSession = Section(header: "Tokens", footer: "")
        tokenSession.tag = "tokenSession"

        for token in self.wallet!.tokens {
            
            let deleteAction = SwipeAction.init(style: .destructive, title: "Delete") { (action, row, handler) in
                self.deleteToken(token)
                tokenSession.remove(at: row.indexPath!.row)
                handler?(true)
            }
            
            tokenSession <<< WalletTokenRow { (row: WalletTokenRow ) in
                row.tag = token.contractAddress
                row.value = token
                row.trailingSwipe.actions = [deleteAction]
                row.trailingSwipe.performsFirstActionWithFullSwipe = true
            }
        }

        tokenSession <<< LeftAlignedButtonRow { row in
            row.tag = "AddTokenRow"
            row.cellStyle = .default
            row.title = "Add Token ..."

            }.onCellSelection({ (_, _) in
                self.navigationController?.pushViewController(AddTokenViewController(delegate: self), animated: true)
            })

        form +++ tokenSession

    }
    
    
    func reloadTokenSession() {
        if let tokenSession = self.form.sectionBy(tag: "tokenSession") {
            
            tokenSession.removeAll()
            
            for token in self.wallet!.tokens {
                tokenSession <<< WalletTokenRow { (row: WalletTokenRow ) in
                    row.tag = token.contractAddress
                    row.value = token
                }
            }
            
            
            tokenSession <<< LeftAlignedButtonRow { row in
                row.cellStyle = .default
                row.title = "Add Token ..."
                
                }.onCellSelection({ (_, _) in
                    self.navigationController?.pushViewController(AddTokenViewController(delegate: self), animated: true)
                })
            
        }

    }
    
    func updateView() {
        

        UIView.performWithoutAnimation {
            // Update Wallet Info
            if let walletInfoSession = self.form.sectionBy(tag: "walletInfoSession") {
                walletInfoSession.forEach { row in
                    row.updateCell()
                }
            }
            
            
            // Update Tx
            
            if let txSession = self.form.sectionBy(tag: "txSession") {
                txSession.evaluateHidden()
                txSession.forEach { row in
                    row.updateCell()
                }
            }

            // Update Tokens
            if let tokenSession = self.form.sectionBy(tag: "tokenSession") {
                
                tokenSession.forEach({ row in
                    if row is WalletTokenRow {
                        let tokenRow = row as! WalletTokenRow
                        if let token = self.wallet!.tokens.first(where: { (aToken) -> Bool in
                            return aToken.contractAddress == tokenRow.tag!
                        }) {
                            tokenRow.value = token
                            tokenRow.updateCell()
                        }
                    }
                })
            }

        }
        

        
    }
    
    func reloadData() {

        // Update Wallet Info
        
        self.wallet = MeowManager.shared.wallet
        
        // Update Last Tx

        if let lastTxObj = MeowDatabase.realm.objects(MeowTransactionHistoryObject.self).sorted(byKeyPath: "time", ascending: false).first {
            self.lastTx = MeowTransactionHistory.init(managedObject: lastTxObj)
        }
        
        MeowManager.Operation.updateTokenBalance()

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wallet = MeowManager.shared.wallet

        setupNavigationItem()

        setupWalletInfoSession()
        setupTransactionSession()
        setupTokenSession()
        
        reloadData()
        updateView()
        
    }

    
    
    @objc func close() {
        MeowManager.shared.dismiss()
    }

    @objc func setting() {
        self.onShowWalletSettingViewController()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "showReceive":
            let receiveVC = segue.destination as! ReceiveEtherViewController
            receiveVC.wallet = self.wallet
        case "showWalletInfo":
            let walletInfoVC = segue.destination as! WalletInfoViewController
            walletInfoVC.wallet = self.wallet
            
        default:
            return
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MeowManager.shared.networkSync()
        reloadData()
        updateView()
    }
    
    func onAddNewToken(token: MeowToken) {
        self.wallet = MeowManager.shared.wallet!
        reloadTokenSession()
    }

    

}
