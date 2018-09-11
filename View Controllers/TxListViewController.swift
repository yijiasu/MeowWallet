//
//  TxListViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 15/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Eureka

class TxListViewController: FormViewController {

    var section : Section?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Transactions"
        self.section = Section("Transactions")
        form +++ self.section!

        self.updateTransactions()
        
        
    }
    
    
    func updateTransactions() {
        
        self.section?.removeAll()
        MeowDatabase.realm.objects(MeowTransactionHistoryObject.self).sorted(byKeyPath: "time", ascending: false).forEach { txObject in
            
            let tx = MeowTransactionHistory.init(managedObject: txObject)
            
            let row = TransactionHistoryRow { row in
                row.value = tx
                }.onCellSelection({ (_, _) in
                    self.navigationController?.pushViewController(TxDetailViewController.init(transactionHistory: tx), animated: true)
                })
            
            self.section! <<< row
        }
        
    }

}
