//
//  MeowManager.swift
//  ARLandOne
//
//  Created by Su Yijia on 10/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import RealmSwift
import EthereumKit

struct MeowManagerOperation {
    
    private let manager : MeowManager
    init() {
        self.manager = MeowManager.shared
    }
    
    // Sync Tx history with online blockchain
    func syncTransactionHistory() {
        self.manager.netClient.getTransactionHistory(wallet: self.manager.wallet!) { allTxHistory in

            // update to DB
            
            let container = try! MeowContainer()
            
            try! container.write { writeTx in
                allTxHistory?.forEach({ txHistory in
                    writeTx.add(txHistory, update: true)
                })
            }

        }
    }
    
    func updateTokenBalance() {
        
        let tokenObjects = MeowDatabase.realm.objects(MeowTokenObject.self)
//        var tokens : [MeowToken] = []

        for tokenObj in tokenObjects {
            
            var walletToken = MeowToken.init(managedObject: tokenObj)
            self.manager.netClient.getTokenBalance(type: walletToken.type ,wallet: self.manager.wallet!, token: walletToken, callback: { balance in
                
                guard let balance = balance else { return }
                walletToken.balanceInWei = balance
                
                let container = try! MeowContainer()
                
                try! container.write { tx in
                    tx.add(walletToken, update: true)
                }
                
                if let tokenIndex = self.manager.wallet!.tokens.index(where: { $0 == walletToken }) {
                    self.manager.wallet!.tokens[tokenIndex] = walletToken
                }
            })

        }

    }
    
}

class MeowManager : MeowAutoLockTimerDelegate {

    static let Operation = MeowManagerOperation()
    static let shared = MeowManager()
    
    public var wallet : MeowWallet?
    public let keystore = MeowKeyStore.shared
    public let netClient = MeowNetClient()
    private let server = MeowHTTPServer()
    public let currencyConverter = MeowCurrencyConverter()
    private var autoLockTimer: MeowAutoLockTimer!
    
//    private var walletVC : MeowNavigationViewController!
    private var welcomeVC : MeowNavigationViewController!
    
    lazy var walletVC: MeowNavigationViewController = {
        return MeowNavigationViewController(rootViewController: WalletViewController())
    }()
    
    lazy var lockScreenVC : MeowNavigationViewController = {
        return MeowNavigationViewController(rootViewController: self.passcodeVC)
    }()

    lazy var passcodeVC : LockScreenViewController = {
        return LockScreenViewController()
    }()

    public var activeWalletNavigationVC : MeowNavigationViewController?
    private var displayingView : UIView?
    private var maskLayerView: UIView?
    public var currentETHNetwork: String?
    
    var onDismiss: (() -> Void)?
    var onCreated: ((_ ethAddress: String) -> Void)?

    var isWalletInitialized: Bool {
        get { return self.keystore.isInitialized }
    }
    
    init() {
        
        
        // try initialze
        log.verbose(MeowDatabase.realm.objects(MeowWalletObject.self))
        
        reloadWallet()
        
        log.verbose(MeowDatabase.realm)
        self.autoLockTimer = MeowAutoLockTimer.init(delegate: self)
        
    }

    
    @objc func dismissInViewController() {
        self.dismiss()
    }
    
    func reloadWallet() {

        if MeowDatabase.realm.objects(MeowWalletObject.self).count != 0 {
            // DB is init
            let wallet = MeowWallet(managedObject: MeowDatabase.realm.objects(MeowWalletObject.self).first!)
            self.wallet = wallet
        }
        else {
            if keystore.isInitialized {
                // Keystore is Initialized
                // but db is lost, try to restore db
                
                if let walletAddress = keystore.defaultETHAddress() {
                    self.wallet = MeowWallet.init(name: nil, address: walletAddress)
                }
            }
        }

    }
    
    func dismiss() {
        
        if let view = displayingView, let mask = maskLayerView {
            view.removeFromSuperview()
            mask.removeFromSuperview()
        }
        
        // if not init, just dismiss
        self.keystore.willDismiss()

        if self.keystore.isInitialized {
            // if need to lock
            if !self.keystore.isLocked {
                
                if MeowDefaults.shared.get(for: MeowDefaults.Keys.AutoLock.Enabled) {
                    if MeowDefaults.shared.get(for: MeowDefaults.Keys.AutoLock.LockTime) == 0 {
                        self.lock()
                    }
                    else {
                        self.autoLockTimer.onUserDismiss()
                    }
                }
                
            }

        }
        
        
        if let onDismiss = self.onDismiss {
            onDismiss()
        }
        
    }
    
    #if DEBUG
    @objc func onDebugDismiss() {
        dismiss()
    }
    #endif
    
    func present(viewController: UIViewController) {
        
        var childVC : UIViewController
        if keystore.isInitialized {
            if keystore.isLocked {
                childVC = lockScreenVC
            }
            else {
                childVC = walletVC
            }
        }
        else {
            welcomeVC = MeowNavigationViewController(rootViewController: WelcomeViewController())
            childVC = welcomeVC
        }

        // add shadow layer
        
        let mask = UIView.init(frame: UIScreen.main.bounds)
        mask.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        mask.alpha = 0
        
        viewController.view.addSubview(mask)
        UIView.animate(withDuration: 0.2) {
            mask.alpha = 1
        }
        #if DEBUG
        let debugDismissButton = UIButton.init(type: .system)
        debugDismissButton.setTitle("[Force Dismiss]", for: .normal)
        debugDismissButton.addTarget(self, action: #selector(onDebugDismiss), for: .touchUpInside)
        debugDismissButton.frame = CGRect(x: 50, y: 50, width: 130, height: 44)
        
        mask.addSubview(debugDismissButton)
        #endif
        maskLayerView = mask
        
        let mainViewRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.85, height: 340)

        viewController.addChildViewController(childVC)
        childVC.view.frame = mainViewRect
        
//        childVC.view.layer.borderColor = UIColor.gray.cgColor
//        childVC.view.layer.borderWidth = 1.0
        childVC.view.layer.cornerRadius = 8
        childVC.view.layer.masksToBounds = true
        childVC.view.center = UIApplication.shared.keyWindow!.center
        


        viewController.view.addSubview(childVC.view)
        childVC.didMove(toParentViewController: viewController)
        
        self.displayingView = childVC.view
        
        
        log.verbose(self.netClient.dataEncoder.callDataForERC20TokenName())
        
        if let _ = self.wallet {
            self.networkSync()
            MeowManager.Operation.syncTransactionHistory()
        }
        
        self.autoLockTimer.onUserActivitiy()

    }

    
    func syncDatabase() {
        
        let container = try! MeowContainer()
        
        try! container.write { tx in
            tx.add(self.wallet!, update: true)
        }

    }
    
    func updateWalletAndSync(_ wallet: MeowWallet) {
        
        updateWallet(wallet)
        syncDatabase()
        
    }
    
    func updateWallet(_ wallet: MeowWallet) {
        
        self.wallet = wallet
    }
    
    func networkSync() {
        
        if let wallet = self.wallet {
            
            self.netClient.getBalance(wallet: wallet) { balanceInWei in
                if let wei = balanceInWei {
                    log.verbose("Balance In Wei" + wei.asString(withBase: 10))
                    self.wallet!.balanceInWei = wei
                    self.syncDatabase()
                    
                    self.netClient.getCurrencyValue(wei: wei, callback: { usdValue in
                        
                        if let usdValue = usdValue {
                            
                            let ether = Double(EthereumKit.Converter.toEther(wei: wei).decimalExpansion(precisionAfterComma: 4))!
                            let totalValue = usdValue * ether
                            log.verbose("Price In USD: " + String(totalValue))
                            self.wallet!.currencyBalance = totalValue
                            self.syncDatabase()

                        }
                        
                    })
                }
            }
            
        }
    }
    
    func makeTransaction(tx: MeowTransaction) {
        
        if let parentVC = self.activeWalletNavigationVC {
            let txVC = ConfirmTxViewController.init(transaction: tx)
            parentVC.pushViewController(txVC, animated: true)
        }
        
    }
    
    func registerActiveWalletNavigationViewController(navVC: MeowNavigationViewController) {
        log.info("registerActiveWalletNavigationViewController ===" + navVC.description)
        self.activeWalletNavigationVC = navVC
    }
    
    func signTransaction(tx: MeowTransaction,  callback: @escaping (_ signedTx: String?) -> Void) {
        
        // 1. get nonce
        self.netClient.getNonce(wallet: self.wallet!) { nonce in
            if let nonce = nonce {
                
                let rawTransaction = tx.toRawTransaction(nonce: nonce)
                do {
                    let signedTx = try self.keystore.signTransaction(tx: rawTransaction)
                    callback(signedTx)
                }
                catch MeowKeyStoreError.notAuthorized {
                    MeowUtil.alert(message: "Send transaction failed. Please unlock your wallet first.")
                    callback(nil)
                }
                catch {
                    callback(nil)
                }

                
            }
            else {
                MeowUtil.alert(message: "Network Error. Get Nonce Failed")
                callback(nil)
            }
        }
        
    }
    
    func updateWalletAddress(address: String) {
        if var wallet = self.wallet {
            wallet.address = address
            updateWalletAndSync(wallet)
        }
    }
    
    func lock() {
        
        self.keystore.lock()
        self.activeWalletNavigationVC?.popToRootViewController(animated: true)
        self.activeWalletNavigationVC?.popViewController(animated: false)
        
        self.activeWalletNavigationVC?.pushViewController(self.passcodeVC, animated: false)
        
    }

    func timerRequestLock() {
        DispatchQueue.main.async {
            self.lock()
        }
    }
}
