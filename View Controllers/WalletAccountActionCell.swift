//
// Created by Su Yijia on 12/5/2018.
// Copyright (c) 2018 Su Yijia. All rights reserved.
//

import Foundation
import Eureka

final class WalletAccountActionCell: Cell<NSNull>, CellType {
    
    public var onSend: (() -> Void)?
    public var onReceive: (() -> Void)?
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setup() {
        super.setup()
        self.selectionStyle = .none

        self.height = {
            return 44
        }
    }
    
    @IBAction func onTapSend(_ sender: Any) {
        guard let action = self.onSend else { return }
        action()
    }
    
    
    @IBAction func onTapReceive(_ sender: Any) {
        guard let action = self.onReceive else { return }
        action()
    }
}

final class WalletAccountActionRow: Row<WalletAccountActionCell>, RowType {

    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<WalletAccountActionCell>(nibName: "WalletAccountAction")
    }

}
