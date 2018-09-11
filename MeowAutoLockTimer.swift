//
//  MeowAutoLockTimer.swift
//  ARLandOne
//
//  Created by Su Yijia on 26/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation

protocol MeowAutoLockTimerDelegate {
    func timerRequestLock()
}

class MeowAutoLockTimer {
    
    let queue : DispatchQueue
    let delegate: MeowAutoLockTimerDelegate
    
    var lastWorkItem : DispatchWorkItem?
    
    init(delegate: MeowAutoLockTimerDelegate) {
        self.delegate = delegate
        self.queue = DispatchQueue.init(label: "meow.autolock.timerqueue")
    }
    
    func onUserActivitiy() {
        
        // Cancel Work Item
        if let workItem = self.lastWorkItem {
            workItem.cancel()
            self.lastWorkItem = nil
        }
        
    }
    
    func onUserDismiss() {
        
        if MeowDefaults.shared.get(for: MeowDefaults.Keys.AutoLock.Enabled) {
            
            let autoLockTime = MeowDefaults.shared.get(for: MeowDefaults.Keys.AutoLock.LockTime)
            
            let workItem = DispatchWorkItem {
                self.delegate.timerRequestLock()
            }
            
            self.queue.asyncAfter(deadline: .now() + .seconds(autoLockTime * 60), execute: workItem)
            
            self.lastWorkItem = workItem

        }
    }
    
}
