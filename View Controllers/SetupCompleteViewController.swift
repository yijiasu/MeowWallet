//
//  SetupCompleteViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 8/6/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

class SetupCompleteViewController: MeowAlertViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        MeowManager.shared.reloadWallet()

        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Create Wallet"

        setupView()
        buttons = [MeowAlertViewButtonItem(title: "Show Wallet", action: {
            
            HUD.show(.progress)
            if let onCreated = MeowManager.shared.onCreated {
                onCreated(MeowManager.shared.keystore.defaultETHAddress()!)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                self.navigationController?.pushViewController(WalletViewController(), animated: false)
                for vc in (self.navigationController?.viewControllers)! {
                    if !(vc is WalletViewController) {
                        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.index(of: vc))!)
                    }
                }
                HUD.hide(afterDelay: 0.1)

            }


//            self.navigationController?.viewControllers.remove(at: 0)
        })]
        
    }
    
    func setupView() {
        let imageView = UIImageView.init(image: R.image.walletDone()!)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        
        let titleLabel = UILabel()
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        titleLabel.text = "It's done"
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        
        
        let secondLabel = UILabel()
        view.addSubview(secondLabel)
        secondLabel.snp.makeConstraints { (make) in
            
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            
            
        }
        secondLabel.text = "Your wallet is created and ONLY stored in your device.\nNever tell your mnemonic words or passcode to anyone."
        secondLabel.font = UIFont.systemFont(ofSize: 12)
        secondLabel.numberOfLines = 0
        secondLabel.textAlignment = .center

    }
}
