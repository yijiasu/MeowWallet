//
//  LockScreenViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 11/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import PKHUD
class LockScreenViewController: MeowAlertViewController {

    private var codeInputField: MeowPasscodeInputField!
    private var titleLabel: UILabel!

    private let keystore = MeowKeyStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarItem()
        setupView()
        
        // Do any additional setup after loading the view.

    }
    
    func setupBarItem() {

        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItems = [closeButton]
        self.navigationItem.title = "Unlock"
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
        titleLabel.text = "Enter Passcode"

        
        codeInputField = MeowPasscodeInputField()
        contentView.addSubview(codeInputField)
        codeInputField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(67)
            make.top.equalTo(titleLabel.snp.bottom).offset(44)
        }
        
        codeInputField.secure = true
        
        codeInputField.onSubmitCode = { code in
            self.validate(passcode: code)
            self.codeInputField.clear()
        }
        
        codeInputField.onEnterDigit = { _ in
            self.onDigitInput()
        }

    }
    
    func onWrongPasscode() {
        
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.text = "Incorrect Passcode"
        titleLabel.textColor = UIColor.red

    }
    
    func onDigitInput() {
        
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.text = "Enter Passcode"
        titleLabel.textColor = UIColor.black
        
    }
    
    @objc func close() {
        MeowManager.shared.dismiss()
    }

    func validate(passcode: String) {
        
        HUD.show(.progress)
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            do {
                try self.keystore.unlockWith(passcode: passcode)
            } catch MeowKeyStoreError.passcodeLengthNotAllowed {
                DispatchQueue.main.async {
                    HUD.hide(animated: false)
                    MeowUtil.alert(message: "Passcode Length must be 4-digit")
                }
            }
            catch MeowKeyStoreError.unlockError
            {
                DispatchQueue.main.async {
                    HUD.hide(animated: false)
//                    MeowUtil.alert(message: "Passcode verification failed")
                    self.onWrongPasscode()
                }
            }
            catch {
                DispatchQueue.main.async {
                    HUD.hide(animated: false)
                    MeowUtil.alert(message: error.localizedDescription)
                }
            }
            
            if (!self.keystore.isLocked) {
                DispatchQueue.main.async {
                    HUD.hide(animated: false)
                    MeowManager.shared.registerActiveWalletNavigationViewController(navVC: self.navigationController as! MeowNavigationViewController)
//                    self.performSegue(withIdentifier: "showMain", sender: nil)
                    self.navigationController?.pushViewController(WalletViewController(), animated: true)
                    self.removeFromParentViewController()
                }
            }


        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.codeInputField.clear()
    }

    
}
