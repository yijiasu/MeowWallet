//
//  AddTokenViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 15/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Eureka
import PKHUD

protocol AddTokenViewControllerDelegate {
    func onAddNewToken(token: MeowToken)
}

class AddTokenViewController: FormViewController {

    var delegate: AddTokenViewControllerDelegate?
    
    init(delegate: AddTokenViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Add Token"
        
        form +++ Section("Token Info")
            <<< TextRow("contractAddress") { row in
                
                row.cell.titleLabel?.removeFromSuperview()
                row.placeholder = "Contract Address"
                
        }
        
            <<< PushRow<MeowTokenType>("tokenType") { row in
                row.title = "Token Type"
                row.options = [.ERC20, .ERC721]
                row.value = .ERC20
        }

        form +++ Section() <<< ButtonRow { row in
            row.title = "Add Token"
            }.onCellSelection({ (_, _) in
                self.addToken()
            })

    }
    
    func addERC20Token(address: String) {
        
        let type = MeowTokenType.ERC20
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()

        MeowManager.shared.netClient.getTokenName(type: type, address: address) { tokenName in
            if let tokenName = tokenName {
                MeowManager.shared.netClient.getTokenSymbol(type: type, address: address, callback: { tokenSymbol in
                    if let tokenSymbol = tokenSymbol {
                        MeowManager.shared.netClient.getERC20TokenDecimal(address: address, callback: { tokenDecimals in
                            if let tokenDecimals = tokenDecimals {
                                PKHUD.sharedHUD.hide(false)
                                
                                let confirmMsg = "Add \(tokenName)\n (\(tokenSymbol))?"
                                log.debug(confirmMsg)
                                MeowUtil.confirm(message: confirmMsg, callback: {
                                    
                                    log.debug("confirm add token")
                                    let token = MeowToken.init(contractAddress: address, symbol: tokenSymbol, type: type, decimal: tokenDecimals)
                                    var wallet = MeowManager.shared.wallet!
                                    
                                    wallet.tokens.append(token)
                                    
                                    MeowManager.shared.updateWalletAndSync(wallet)
                                    
                                    if let delegate = self.delegate {
                                        delegate.onAddNewToken(token: token)
                                    }
                                    self.navigationController?.popViewController(animated: true)

                                })
                                
                                
                            }
                            else {
                                PKHUD.sharedHUD.hide(false)
                                MeowUtil.alert(message: "This token is not recoginzed. Meow only support ERC-20 and ERC-721 token.")
                            }
                        })
                    }
                    else {
                        PKHUD.sharedHUD.hide(false)
                        MeowUtil.alert(message: "This token is not recoginzed. Meow only support ERC-20 and ERC-721 token.")
                    }
                })
            }
            else {
                PKHUD.sharedHUD.hide(false)
                MeowUtil.alert(message: "This token is not recoginzed. Meow only support ERC-20 and ERC-721 token.")
            }
        }
        

        
    }
    
    func addERC721Token(address: String) {
        
        
        let type = MeowTokenType.ERC721
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        MeowManager.shared.netClient.getTokenName(type: type, address: address) { tokenName in
            if let tokenName = tokenName {
                MeowManager.shared.netClient.getTokenSymbol(type: type, address: address, callback: { tokenSymbol in
                    if let tokenSymbol = tokenSymbol {
                        
                        // Check if ownerOf method existed
                        MeowManager.shared.netClient.getERC721TokenOwnerOf(address: address, tokenId: 1, callback: { ownerAddress in
                            if let ownerAddress = ownerAddress {
                                // passed erc-721 check

                                PKHUD.sharedHUD.hide(false)
                                log.verbose(ownerAddress)

                                let confirmMsg = "Add \(tokenName)\n (\(tokenSymbol))?"
                                MeowUtil.confirm(message: confirmMsg, callback: {

                                    log.debug("confirm add token  --- erc 721")
                                    let token = MeowToken.init(contractAddress: address, symbol: tokenSymbol, type: MeowTokenType.ERC721, decimal: 0)
                                    var wallet = MeowManager.shared.wallet!

                                    wallet.tokens.append(token)

                                    MeowManager.shared.updateWalletAndSync(wallet)

                                    if let delegate = self.delegate {
                                        delegate.onAddNewToken(token: token)
                                    }
                                    self.navigationController?.popViewController(animated: true)

                                })

                            }
                            else {
                                PKHUD.sharedHUD.hide(false)
                                MeowUtil.alert(message: "This token is not ERC-721 type.")
                            }
                        })
                        
//                        MeowManager.shared.netClient.getERC20TokenDecimal(address: address, callback: { tokenDecimals in
//                            if let tokenDecimals = tokenDecimals {
//
//
//                            }
//                            else {
//                                PKHUD.sharedHUD.hide(false)
//                                MeowUtil.alert(message: "This token is not recoginzed. Meow only support ERC-20 and ERC-721 token.")
//                            }
//                        })
                    }
                    else {
                        PKHUD.sharedHUD.hide(false)
                        MeowUtil.alert(message: "This token is not recoginzed. Meow only support ERC-20 and ERC-721 token.")
                    }
                })
            }
            else {
                PKHUD.sharedHUD.hide(false)
                MeowUtil.alert(message: "This token is not recoginzed. Meow only support ERC-20 and ERC-721 token.")
            }
        }
        

        
    }
    
    func addToken() {
        
        let values = self.form.values()
        log.debug(values)
        
        guard let address = values["contractAddress"] as? String, MeowUtil.verifyETHAddress(address: address) else {
            MeowUtil.alert(message: "Please enter a valid token contract address.")
            return
        }
        
        if MeowDatabase.realm.objects(MeowTokenObject.self).filter("contractAddress = '" + address + "'").count != 0 {
            MeowUtil.alert(message: "You have already added this token.")
            return
        }
        
        let tokenType = values["tokenType"] as! MeowTokenType
        
        
        switch tokenType {
        case .ERC20:
            addERC20Token(address: address)
            break
        case .ERC721:
            addERC721Token(address: address)

        }
    }


}
