//
//  WalletAccountInfoCell.swift
//  ARLandOne
//
//  Created by Su Yijia on 12/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Eureka
import BlockiesSwift

final class WalletAccountInfoCell: Cell<MeowWallet>, CellType {

    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ethBalanceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!

    @IBOutlet weak var avatarImageView: UIImageView!

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateView() {
        
        guard let wallet = row.value else { return }
        
        self.accountNameLabel.text = wallet.displayName
        self.addressLabel.text = wallet.address
        
        if let ethBalance = wallet.ether {
            let displayBalance = ethBalance.decimalExpansion(precisionAfterComma: 6)
            self.ethBalanceLabel.text = displayBalance + " "  + "ETH"
            if let usdBalance = MeowManager.shared.currencyConverter.convertToUSDInString(from: wallet.balanceInWei!) {
                self.currencyLabel.text = "(" + usdBalance + ")"
            }
        }
        else {
            self.ethBalanceLabel.text = "...."
            self.currencyLabel.text = "(....)"

        }
        
        let blockies = Blockies(
            seed: wallet.address.lowercased(),
            size: 8,
            scale: 16
        )

        self.avatarImageView.image = blockies.createImage()
        self.avatarImageView.layer.cornerRadius = CGFloat(Float(self.avatarImageView.frame.size.width) / Float(2))
        self.avatarImageView.layer.masksToBounds = true
        self.height = {
            return 80.0
        }

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


}

final class WalletAccountInfoRow: Row<WalletAccountInfoCell>, RowType {

    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<WalletAccountInfoCell>(nibName: "WalletAccountInfo")
    }
    func update() {
        cell.updateView()
    }

}
