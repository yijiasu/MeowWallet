//
//  MeowDatabase.swift
//  ARLandOne
//
//  Created by Su Yijia on 16/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import RealmSwift
public final class MeowDatabase {
    static var realm : Realm = {
        
        var dbConfig = Realm.Configuration()
        
        dbConfig.schemaVersion = 1
        dbConfig.migrationBlock = { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }

        dbConfig.fileURL = dbConfig.fileURL!.deletingLastPathComponent().appendingPathComponent("meow.realm")
        
        return try! Realm(configuration: dbConfig)

    }()
}

public final class WriteTransaction {
    private let realm: Realm
    internal init(realm: Realm) {
        self.realm = realm
    }
    public func add<T: MeowPersistable>(_ value: T, update: Bool) {
        realm.add(value.managedObject(), update: update)
    }
}

public final class MeowContainer {
    private let realm: Realm
    public convenience init() throws {
        try self.init(realm: MeowDatabase.realm)
    }
    internal init(realm: Realm) {
        self.realm = realm
    }
    public func write(_ block: (WriteTransaction) throws -> Void)
        throws {
            let transaction = WriteTransaction(realm: realm)
            try realm.write {
                try block(transaction)
            }
    }
}

