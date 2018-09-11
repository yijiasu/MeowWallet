//
//  SendEtherViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 14/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Eureka
import EthereumKit

class SendEtherViewController: FormViewController {

    private var wallet : MeowWallet!
    private var isScanning  = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
//    convenience init() {
//        self.init()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    init(transaction: MeowTransaction) {
//        self.tx = transaction
//        super.init(nibName: nil, bundle: nil)
//    }
    
    override func insertAnimation(forSections sections: [Section]) -> UITableViewRowAnimation {
        return .top
    }
    
    override func deleteAnimation(forSections sections: [Section]) -> UITableViewRowAnimation {
        return .top
    }

    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        self.wallet = MeowManager.shared.wallet
        
        self.navigationItem.title = "Send Ether"
        
        let scannerSection = Section()
        scannerSection.tag = "scannerSection"
        scannerSection.hidden = true
        
        let scannerRow = AddressScannerRow()
        scannerRow.tag = "scannerRow"
        scannerRow.onScannedAddress { address in
            self.fillAddress(address: address)
            self.isScanning = false
            scannerSection.hidden = true
            scannerSection.evaluateHidden()
            scannerRow.stopScan()
        }
        
        scannerSection <<< scannerRow

        
        form +++ scannerSection
        
        let recipientSection = Section("Recipient")
        recipientSection.tag = "recipientSection"
        
        recipientSection <<< TextRow { row in
            row.tag = "to"
            row.cell.titleLabel?.removeFromSuperview()
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            button.tintColor = UIColor.red
            button.setTitleColor(UIColor.red, for: .normal)
            button.setImage(UIImage.init(named: "qr-code"), for: .normal)
            button.addTarget(self, action: #selector(onStartScan), for: .touchUpInside)
            
            row.cell.accessoryView = button
            
            row.placeholder = "ETH Address"
        }

        
        form +++ recipientSection
        
        form +++ Section("Amount")
            <<< TextRow { row in
                
                row.tag = "amount"

                row.cell.titleLabel?.removeFromSuperview()
                row.placeholder = "Amount"
        }
        
        form +++ Section()
            <<< ButtonRow { row in
                row.title = "Send"
                }.onCellSelection({ (_, _) in
                    self.makeTransfer()
                })
        
    }
    
    func makeTransfer() {
        
        let values = self.form.values()
        
        guard let toAddress = values["to"] as? String, MeowUtil.verifyETHAddress(address: toAddress) else {
            MeowUtil.alert(message: "Please enter a valid token contract address.")
            return
        }
        
        guard let amount = values["amount"] as? String, Double.init(string: amount) != nil else {
            MeowUtil.alert(message: "Please enter valid amount.")
            return
        }
        
        guard let ether = Ether.init(amount) else {
            MeowUtil.alert(message: "Please enter valid amount.")
            return
        }
        
        if Converter.toWei(ether: ether) > self.wallet.balanceInWei! {
            MeowUtil.alert(message: "Insufficient fund.")
            return

        }
        
        let tx = MeowTransaction.init(from: self.wallet.address,
                                      to: toAddress,
                                      amount:Converter.toWei(ether: ether),
                                      gasLimit: 21000, gasPrice: 5,
                                      data: Data())
        
        MeowManager.shared.makeTransaction(tx: tx)
        
    }
    
    func fillAddress(address: String) {
        
        let row : TextRow = form.sectionBy(tag: "recipientSection")!.rowBy(tag: "to")!
        
        row.value = address
        row.updateCell()
        
    }

    @objc func onStartScan() {
        
        self.isScanning = !self.isScanning
        updateScannerUI()
        
    }
    
    func updateScannerUI() {
        
        let section = form.sectionBy(tag: "scannerSection")!
        section.hidden = isScanning ? false : true
        section.evaluateHidden()
        
        let row : AddressScannerRow = section.rowBy(tag: "scannerRow")!
        if isScanning
        {
            row.startScan()
        }
        else {
            row.stopScan()
        }

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.isScanning = false
        updateScannerUI()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isScanning && section == 0 {
            return 20
        }
        else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
}
