//
//  ReceiveEtherViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 14/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import QRCode

class ReceiveEtherViewController: UIViewController {

    private var ethAddressLabel: UILabel!
    private var QRCodeImageView: UIImageView!
    var wallet: MeowWallet!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.wallet = MeowManager.shared.wallet
        setupView()
        
    }

    
    func setupView() {
        
        self.view = UIView()
        view.backgroundColor = UIColor.white
        QRCodeImageView = UIImageView()
        view.addSubview(QRCodeImageView)
        QRCodeImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(128)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(74)
        }
        
        
        ethAddressLabel = UILabel()
        view.addSubview(ethAddressLabel)
        ethAddressLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(QRCodeImageView.snp.bottom).offset(40)
        }
        
        ethAddressLabel.font = UIFont.systemFont(ofSize: 9)
        
        self.navigationItem.title = "Receive Ether"

        if let wallet = self.wallet {
            self.ethAddressLabel.text = wallet.address
            self.QRCodeImageView.image = QRCode(wallet.address)?.image
        }
    }


}
