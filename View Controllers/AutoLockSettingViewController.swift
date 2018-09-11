//
//  AutoLockSettingViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 25/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import Eureka

class AutoLockSettingViewController : FormViewController {
    
    let autoLockSettings = ["Immediately After Close", "1 Minute", "2 Minutes", "5 Minutes", "Never"]
    let autoLockTime = [0, 1, 2, 5, nil]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Auto Lock"
        
        let section = SelectableSection<ListCheckRow<Int>>("", selectionType: .singleSelection(enableDeselection: false))
        
        let autoLockEnabled = MeowDefaults.shared.get(for: MeowDefaults.Keys.AutoLock.Enabled)
        let lockTime = MeowDefaults.shared.get(for: MeowDefaults.Keys.AutoLock.LockTime)
        let selectedIndex = autoLockEnabled ? autoLockTime.index(of: lockTime)! : autoLockTime.count - 1
        
        section.onSelectSelectableRow = { (cell, row) in
            self.onSelectOptions(index: row.selectableValue!)
        }
        
        for option in autoLockSettings {
            section <<< ListCheckRow<Int>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = autoLockSettings.index(of: option)
//                listRow.cell.accessoryType = selectedIndex == autoLockSettings.index(of: option) ? .checkmark : .none
                log.verbose(listRow.cell)
                }.onCellSelection({ (cell, row) in
                    self.onSelectOptions(index: row.selectableValue!)
                })
        }
        
        let row = section[selectedIndex] as! ListCheckRow<Int>
        row.didSelect()

        form +++ section
        
    }
    
    func onSelectOptions(index: Int) {
//        MeowUtil.alert(message: String(index))
        
        let locktime = self.autoLockTime[index]
        if let time = locktime {
            // not nil, set auto lock time
            MeowDefaults.shared.set(true, for: MeowDefaults.Keys.AutoLock.Enabled)
            MeowDefaults.shared.set(time, for: MeowDefaults.Keys.AutoLock.LockTime)
            
        }
        else {
            // get nil, disable auto lock
            MeowDefaults.shared.set(false, for: MeowDefaults.Keys.AutoLock.Enabled)
            MeowDefaults.shared.set(0, for: MeowDefaults.Keys.AutoLock.LockTime)
        }

    }
}
