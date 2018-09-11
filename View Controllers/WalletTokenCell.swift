//
//  WalletTokenCell.swift
//  ARLandOne
//
//  Created by Su Yijia on 12/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import Eureka

class WalletTokenCell : Cell<MeowToken>, CellType{

    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var tokenTypeLabel: UILabel!
    @IBOutlet weak var tokenBalanceLabel: UILabel!

    override func setup() {

        super.setup()

        self.selectionStyle = .none
        self.accessoryType = .none
        
        updateView()

    }
    
    override func update() {
        super.update()
        updateView()
    }
    
    func updateView() {
        guard let token = row.value else { return }
        
        self.tokenSymbolLabel.text = token.symbol
        self.tokenTypeLabel.text = token.type.rawValue
        if let balance = token.balance {
            switch token.type {
            case .ERC20:
                self.tokenBalanceLabel.text = balance.decimalExpansion(precisionAfterComma: 2)
            case .ERC721:
                self.tokenBalanceLabel.text = String(Int(Double(balance.decimalDescription)!))
            }
        }
        else {
            self.tokenBalanceLabel.text = "-"
        }

    }
}

final class WalletTokenRow: Row<WalletTokenCell>, RowType {

    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<WalletTokenCell>(nibName: "WalletToken")
    }

}

