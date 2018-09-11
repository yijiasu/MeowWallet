//
//  TransactionHistoryCell.swift
//  ARLandOne
//
//  Created by Su Yijia on 23/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import Eureka
import EthereumKit
//
//final class WalletAccountActionCell: Cell<NSNull>, CellType {
//
//    public var onSend: (() -> Void)?
//    public var onReceive: (() -> Void)?
//
//    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    override func setup() {
//        super.setup()
//        self.selectionStyle = .none
//
//        self.height = {
//            return 44
//        }
//    }
//
//    @IBAction func onTapSend(_ sender: Any) {
//        guard let action = self.onSend else { return }
//        action()
//    }
//
//
//    @IBAction func onTapReceive(_ sender: Any) {
//        guard let action = self.onReceive else { return }
//        action()
//    }
//}


class TransactionHistoryCell: Cell<MeowTransactionHistory>, CellType {
    
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var ethAmountLabel: UILabel!
    @IBOutlet weak var currencyAmountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressDirectionLabel: UILabel!

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setup() {
        super.setup()
        self.selectionStyle = .none

        updateView()

    }
    
    override func update() {
        super.update()
        updateView()
        
    }

    func updateView() {
        
        self.height = {
            return 80
        }
        
        if let tx = self.row.value {
            
            switch tx.direction(hostAddress: MeowManager.shared.wallet!.address) {
            case .received :
                self.addressDirectionLabel.text = "FROM"
                self.directionLabel.text = "Received"
                self.addressLabel.text = tx.from
                break
                
            case .sent:
                self.addressDirectionLabel.text = "TO"
                self.directionLabel.text = "Sent"
                self.addressLabel.text = tx.to
            }
            
            if let usdAmount = MeowManager.shared.currencyConverter.convertToUSDInString(from: tx.amount) {
                self.currencyAmountLabel.text = "(" + usdAmount + ")"
            }
            else {
                self.currencyAmountLabel.text = "..."
            }
            
            self.ethAmountLabel.text = tx.amount.displayETHValue()

            
        }
    }
    

}

final class TransactionHistoryRow: Row<TransactionHistoryCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TransactionHistoryCell>(nibName: "TransactionHistoryCell")
    }
    
}

