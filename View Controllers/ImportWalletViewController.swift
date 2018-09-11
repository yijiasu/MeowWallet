//
//  ImportWalletViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 8/6/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import UIKit
import EthereumKit

class ImportWalletViewController: MeowAlertViewController {
    
    var textField: UITextView!
    private var keystore = MeowKeyStore.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupButtons()

        self.navigationItem.title = "Import Wallet"

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
        labelOne.text = "Please enter your wallet mnemonic words. \nThe HD derivation path should be m/44'/60'/0'/0"
        
        
    }
    
    func setupButtons() {
        
        buttons = [
            MeowAlertViewButtonItem(title: "Next", action: {
                self.onNext()
            })
        ]
    }
    
    func onNext() {
        
        guard let mnemonicString = textField.text else { return }
        
        if mnemonicString.count == 0 {
            return
        }
        
        let mnemonic = mnemonicString.components(separatedBy: " ")
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        guard let wallet = try? Wallet(seed: seed, network: MeowConfig.ETH.network) else {
            MeowUtil.alert(message: "Mnemonic string not recognized. Please check again")
            return
        }
        
        let address = wallet.generateAddress()
        if address.count != 0 {
            MeowUtil.confirm(message: "Import wallet with ETH address:\n \(address)?") {
                self.importWallet(mnemonicString)
            }
        }
        else {
            MeowUtil.alert(message: "Address cannot be parsed from this mnemonic. Please check again")
            return
        }
        

    }
    
    func importWallet(_ mnemonicString: String) {
        
        do {
            try keystore.importMnemonicString(mnemonicString)
        }
        catch {
            MeowUtil.alert(message: "Unexpected error occurs while importing. Please check again")
            return
        }
        
        self.navigationController?.pushViewController(SetPasscodeViewController(), animated: true)
        
    }
    

    
}
