//
//  MeowDefaults.swift
//  ARLandOne
//
//  Created by Su Yijia on 25/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import DefaultsKit


class MeowDefaults {
    
    
    final class MeowDefaultKey<ValueType: Codable> {
        fileprivate let _key: String
        let _defaultValue: ValueType
        public init(_ key: String, defaultValue: ValueType) {
            self._key = key
            self._defaultValue = defaultValue
        }
    }

    struct Keys {
        struct AutoLock {
            
            static let Enabled = MeowDefaultKey<Bool>.init("MeowWallet.AutoLock.Enabled", defaultValue: true)
            static let LockTime = MeowDefaultKey<Int>.init("MeowWallet.AutoLock.LockTime", defaultValue: 0)

        }
    }
    
    static let shared = MeowDefaults()
    private let defaults = Defaults()
    
    public func get<ValueType>(for key: MeowDefaultKey<ValueType>) -> ValueType {
        let originalKey = Key<ValueType>(key._key)
        if let userDefaultResult = self.defaults.get(for: originalKey) {
            return userDefaultResult
        }
        else {
            return key._defaultValue
        }
    }
    
    public func set<ValueType>(_ value: ValueType, for key: MeowDefaultKey<ValueType>) {
        
        log.info("MeowDefaults --- setDefault --- " + key._key)
        let originalKey = Key<ValueType>(key._key)
        self.defaults.set(value, for: originalKey)
    }
}
