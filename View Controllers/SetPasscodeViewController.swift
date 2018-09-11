//
//  SetPasscodeViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 11/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Alertift
import PKHUD

class SetPasscodeViewController: MeowAlertViewController, UITextFieldDelegate {

    private var codeInputField: MeowPasscodeInputField!
    
    private var repeatMode : Bool = false
    private var firstPasscode : String?
    private var secondPasscode : String?
    
    private let keystore = MeowKeyStore.shared

    private var titleLabel : UILabel!
    private var notMatchLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Create Wallet"

        setupView()
    }

    func setupView() {
        
        titleLabel = UILabel.init()
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(34)
        }
        
        
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.text = "Protect your wallet"
        
        codeInputField = MeowPasscodeInputField()
        contentView.addSubview(codeInputField)
        codeInputField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(67)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        
        codeInputField.secure = true
        
        codeInputField.onEnterDigit = { index in
            self.updateNotMatchLabel(true)
        }
        
        codeInputField.onSubmitCode = { code in
            
            // First Input
            
            if self.repeatMode == false {
                
                self.firstPasscode = code
                self.repeatMode = true
                self.codeInputField.clear()
                
                self.titleLabel.text = "Repeat Your Passcode"
                self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
                
                return
            }
            
            // Second Input
            
            if self.repeatMode == true {
                
                self.secondPasscode = code
                self.validate()

            }
            
        }
        
        notMatchLabel = UILabel.init()
        contentView.addSubview(notMatchLabel)
        notMatchLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(codeInputField.snp.bottom).offset(36)
        }

        notMatchLabel.textAlignment = .center
        notMatchLabel.numberOfLines = 0
        notMatchLabel.font = UIFont.systemFont(ofSize: 14)
        notMatchLabel.textColor = UIColor.red
        notMatchLabel.text = "Passcodes did not match. Try again."
        notMatchLabel.isHidden = true


        let footerLabel = UILabel.init()
        contentView.addSubview(footerLabel)
        footerLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(notMatchLabel.snp.bottom).offset(36)
        }
        
        
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        footerLabel.font = UIFont.systemFont(ofSize: 12)
        footerLabel.text = "Please set a passcode.\nYou must type in the same passcode when access to your wallet."

    }
    
    func reset() {
        
        self.firstPasscode = nil
        self.secondPasscode = nil
        self.repeatMode = false
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.text = "Protect your wallet"
        
        codeInputField.clear()
        
    }
    
    func updateNotMatchLabel(_ isHidden: Bool) {
        notMatchLabel.isHidden = isHidden
        view.layoutSubviews()
    }
    
    
    func validate() {
        
        if self.firstPasscode != self.secondPasscode {

            updateNotMatchLabel(false)
            self.reset()
            
            return
        }
        
        do {
            try keystore.secureWith(passcode: self.firstPasscode!)
        } catch  {
            MeowUtil.alert(message: error.localizedDescription, title: "Error")
        }
        
        try! keystore.unlockWith(passcode: self.firstPasscode!)
        // Create and save in db
        let wallet = MeowWallet(name: nil, address: keystore.defaultETHAddress()!)
        //        let wallet = MeowWallet(name: nil, address: keystore.defaultETHAddress()!, ethBalance: nil, currencyBalance: nil, tokens: [])
        let container = try! MeowContainer()
        
        try! container.write({ (tx) in
            tx.add(wallet, update: false)
        })

        HUD.flash(.progress, onView: self.view, delay: 0.3) { (_) in
            self.navigationController?.pushViewController(SetupCompleteViewController(), animated: true)
        }
    }

    
}
