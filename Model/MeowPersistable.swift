//
//  MeowPersistable.swift
//  ARLandOne
//
//  Created by Su Yijia on 15/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import RealmSwift

public protocol MeowPersistable {
    
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}
