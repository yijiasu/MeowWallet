//
//  CustomizedHeightNavigationBar.swift
//  ARLandOne
//
//  Created by Su Yijia on 11/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit

class CustomizedHeightNavigationBar: UINavigationBar {
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
    }
    
}
