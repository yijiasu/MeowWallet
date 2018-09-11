//
//  LeftAlignedButtonRow.swift
//  ARLandOne
//
//  Created by Su Yijia on 24/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import Eureka


public final class LeftAlignedButtonRow : _ButtonRowOf<String>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    public override func customUpdateCell() {
        super.customUpdateCell()
        cell.textLabel?.textAlignment = .left
    }
}
