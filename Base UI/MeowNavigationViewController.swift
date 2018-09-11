//
//  MeowNavigationViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 10/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit

class MeowNavigationViewController: UINavigationController, UINavigationBarDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        self.navigationBar.barTintColor = UIColor.init(rgb: 0xF7F7F7)
        self.navigationBar.isTranslucent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        log.verbose("pushViewController - " + viewController.description)

    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        log.verbose("popViewController")
        return super.popViewController(animated: animated)

    }
    
 
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            print("keyboardWillShow")

            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let screenHeight = UIScreen.main.bounds.size.height
            
            let newOrigin = CGPoint(x: self.view.frame.origin.x , y: CGFloat((screenHeight - keyboardHeight - CGFloat(MeowConfig.UI.windowHeight)) / 2.0))
            self.view.frame = CGRect(origin: newOrigin, size: self.view.frame.size)

        }

    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        
        let screenHeight = UIScreen.main.bounds.size.height
        
        let newOrigin = CGPoint(x: self.view.frame.origin.x, y: CGFloat((screenHeight - CGFloat(MeowConfig.UI.windowHeight)) / 2.0))
        self.view.frame = CGRect(origin: newOrigin, size: self.view.frame.size)
        
    }

}
