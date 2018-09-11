//
//  String+Optional.swift
//  ARLandOne
//
//  Created by Su Yijia on 16/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation

extension String {
    public func wrap() -> String? {
        if self == "" {
            return nil
        }
        else {
            return self
        }
    }
}
