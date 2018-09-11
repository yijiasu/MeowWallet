//
//  WelcomeViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 10/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit

class WelcomeViewController: MeowAlertViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        self.navigationItem.title = "Meow Wallet"
        
        setupView()
        setupButtons()
    }

    
    @IBAction func onGenerate(_ sender: Any) {
        self.performSegue(withIdentifier: "GenerateNewWallet", sender: nil)
    }
    
    
    func setupView() {
        
        let mainLabel = UILabel()
        
        contentView.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(42)
            make.centerX.equalToSuperview()
        }
        
        mainLabel.text = "Welcome to Meow"
        mainLabel.numberOfLines = 0
        mainLabel.textAlignment = .center
        mainLabel.font = UIFont.systemFont(ofSize: 19)

        
        let secondLabel = UILabel()
        
        contentView.addSubview(secondLabel)
        secondLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mainLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        secondLabel.text = "An Embedded Ethereum Wallet Manager."
        secondLabel.numberOfLines = 0
        secondLabel.textAlignment = .center
        secondLabel.font = UIFont.systemFont(ofSize: 12)
        
        
        let thirdLabel = UILabel()
        
        contentView.addSubview(thirdLabel)
        thirdLabel.snp.makeConstraints { (make) in
            make.top.equalTo(secondLabel.snp.bottom).offset(90)
            make.centerX.equalToSuperview()
        }
        
        thirdLabel.text = "You don't have any wallet managed by Meow.\nPlease create a new one or import."
        thirdLabel.numberOfLines = 0
        thirdLabel.textAlignment = .center
        thirdLabel.font = UIFont.systemFont(ofSize: 12)

        
    }
    
    func setupButtons() {
        
        buttons = [
            MeowAlertViewButtonItem(title: "Create New Wallet", action: {
                self.navigationController?.pushViewController(GenerateWalletViewController(), animated: true)
            }),
            MeowAlertViewButtonItem(title: "Import Existed", action: {
                self.navigationController?.pushViewController(ImportWalletViewController(), animated: true)
            })
            
        ]
    }
    
    
}
