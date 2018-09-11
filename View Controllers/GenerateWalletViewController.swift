//
//  GenerateWalletViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 11/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit

class GenerateWalletViewController: MeowAlertViewController {

    private let keystore = MeowKeyStore.shared
    
    var textField: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupButtons()

        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Create Wallet"
        
        do {
            try keystore.generateKeyStore()
            self.textField.text = try keystore.getMnemonicString()
        } catch MeowKeyStoreError.notAuthorized {
            log.error("MeowKeyStoreError.notAuthorized")
        }
        catch MeowKeyStoreError.alreadyInitializedError {
            MeowUtil.alert(message: "alreadyInitializedError")
        }
        catch {
            MeowUtil.alert(message: error.localizedDescription)
        }
    }

    func setupView() {
        
        textField = UITextView.init()
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(78)
        }
        textField.layer.borderColor = UIColor.init(rgb: 0x8E8E93).cgColor
        textField.layer.borderWidth = 0.5
        textField.font = UIFont.systemFont(ofSize: 18)
        
        let labelOne = UILabel.init()
        contentView.addSubview(labelOne)
        labelOne.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(textField.snp.bottom).offset(12)
        }

        labelOne.textAlignment = .left
        labelOne.numberOfLines = 0
        labelOne.font = UIFont.systemFont(ofSize: 12)
        labelOne.text = "Please write down those word on paper and keep in in someplace safe and secret."
        
        
        let labelTwo = UILabel.init()
        contentView.addSubview(labelTwo)
        labelTwo.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(labelOne.snp.bottom).offset(12)
        }
        
        labelTwo.textAlignment = .left
        labelTwo.numberOfLines = 0
        labelTwo.font = UIFont.systemFont(ofSize: 12)
        labelTwo.textColor = UIColor.red
        labelTwo.text = "REMEMBER: These words are the ONLY way to restore your Meow Wallet. If you lost those words you will lost you wallet and all assets. Never tell your words to anyone."

        
    }

    func setupButtons() {
        
        buttons = [
            MeowAlertViewButtonItem(title: "I've copied it somewhere safe", action: {
                self.navigationController?.pushViewController(CheckMnemonicViewController(), animated: true)
            })
        ]
    }


}
