//
//  String+DeletePrefix.swift
//  ARLandOne
//
//  Created by Su Yijia on 21/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
