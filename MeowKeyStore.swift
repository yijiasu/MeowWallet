//
//  MeowKeyStore.swift
//  ARLandOne
//
//  Created by Su Yijia on 11/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import CryptoSwift
import PathKit
import EthereumKit
import SwiftyBeaver

let log = SwiftyBeaver.self

enum MeowKeyStoreError: Error {
    
    case keyStoreFileNotExisted
    case emptyKeyStoreString
    
    case keyStoreOverwriteDisallowed
    case keyStoreSaveError
    
    case notAuthorized
    
    case passcodeLengthNotAllowed
    case alreadyInitializedError
    case unlockError
    case stateError

}

enum MeowKeyStoreState {
    
    case notInitialized
    case unsecured
    case locked
    case unlocked
    case error
    
}

class MeowKeyStore {


    
    public static let shared = MeowKeyStore()
    
    private let keyStorePath = MeowConfig.KeyStore.keyStoreFilePath
    
    private var mnemonic : [String]?
    private var encryptedData : Data?
    private var errorMessage: String? = nil
    
    private var state: MeowKeyStoreState = .notInitialized
    
    private var wallet: Wallet?
    
    private var addressCache: String?
    
    public var isInitialized: Bool {
        get {
            return self.state != .notInitialized
        }
    }

    public var isLocked: Bool {
        get {
            return self.state == .locked
        }
    }
    
    func willDismiss() {
        if self.state == .unsecured {
            // remove state
            self.mnemonic = nil
            self.state = .notInitialized
        }
    }
    
    init() {
        
        if !FileManager.default.fileExists(atPath: MeowConfig.KeyStore.keyStoreDir) {
            // Not existed
            try? FileManager.default.createDirectory(atPath: MeowConfig.KeyStore.keyStoreDir, withIntermediateDirectories: true, attributes: nil)
        }
        else {
            if FileManager.default.fileExists(atPath: MeowConfig.KeyStore.keyStoreFilePath) {
                // Existed. Load Data
                do {
                    
                    self.encryptedData = try Data.init(contentsOf: URL(fileURLWithPath: self.keyStorePath))
                    self.state = .locked
                    log.info("Load Data OK. Go to LOCKED state")
                    
                    // try load address from file cache
                    self.addressCache = try? String.init(contentsOf: URL(fileURLWithPath: MeowConfig.KeyStore.keyStoreAddressCacheFilePath))
                    
                }
                catch {
                    self.state = .error
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
    }
    
    func importMnemonicString(_ mnemonicString: String) throws {
        
        if (self.state != .notInitialized) {
            throw MeowKeyStoreError.alreadyInitializedError
        }
        
        let mnemonic = mnemonicString.components(separatedBy: " ")
        
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        self.wallet = try Wallet(seed: seed, network: MeowConfig.ETH.network)
        self.mnemonic = mnemonic
        self.state = .unsecured
        log.info("Import Key Store OK")

    }
    
    func getMnemonicString() throws -> String  {
        
        if (self.state != .unsecured && self.state != .unlocked) {
            throw MeowKeyStoreError.notAuthorized
        }
        
        return self.mnemonic!.joined(separator: " ")
    }
    
    func dumpPrivateKey() throws -> String {
        
        if (self.state != .unsecured && self.state != .unlocked) {
            throw MeowKeyStoreError.notAuthorized
        }

        return self.wallet!.dumpPrivateKey()
    }
    
    func keyStoreFileExists() -> Bool {
        
        return FileManager.default.fileExists(atPath: self.keyStorePath)
        
    }
    
    
    func generateKeyStore() throws {
        
        if (self.state != .notInitialized) {
            throw MeowKeyStoreError.alreadyInitializedError
        }
        
        
        log.verbose("start generateing")
        self.mnemonic = Mnemonic.create()
        self.state = .unsecured
        log.info("Generate Key Store OK")

    }
    
    func secureWith(passcode: String) throws {
        
        if (passcode.count != 4) {
            throw MeowKeyStoreError.passcodeLengthNotAllowed
        }
        
        if (self.state != .unsecured) {
            throw MeowKeyStoreError.stateError
        }
        
        let passcodeWithPadding = "MEOW" + passcode + "PASSWORD"
        do {
            let aes = try AES(key: Array(passcodeWithPadding.utf8), blockMode: .CBC(iv: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]))
            let rawData = Array(self.mnemonic!.joined(separator: " ").utf8)
            let hash = rawData.sha1()
            let encryptedData = try aes.encrypt(rawData + hash)
            try Data(encryptedData).write(to: URL(fileURLWithPath: MeowConfig.KeyStore.keyStoreFilePath))
            if self.encryptedData == nil {
                self.encryptedData = Data(encryptedData)
            }
            
        } catch {
            throw MeowKeyStoreError.keyStoreSaveError
        }
        
        self.state = .unlocked
        
        log.info("Secure Data With Passcode OK")
        
        

    }
    
    
    func unlockWith(passcode: String) throws {
        
        if (self.state == .unlocked) {
            try self.initWallet()
            return
        }

        if (passcode.count != 4) {
            throw MeowKeyStoreError.passcodeLengthNotAllowed
        }
        
        
        if (self.state != .locked) {
            throw MeowKeyStoreError.stateError
        }
        
        
        
        let passcodeWithPadding = "MEOW" + passcode + "PASSWORD"
        
        do {
            
            let aes = try AES(key: Array(passcodeWithPadding.utf8), blockMode: .CBC(iv: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]))
            let decrypedBytes = try aes.decrypt(Array(self.encryptedData!))
            if decrypedBytes.count <= 20 {
                throw MeowKeyStoreError.unlockError
            }
            else
            {
                // Got Last 20 Bytes
                let hash = Array<UInt8>(decrypedBytes.suffix(20))
                let bytes = Array<UInt8>(decrypedBytes.prefix(decrypedBytes.count - 20))
                
                if hash == bytes.sha1() {
                    
                    let decryptedData = Data.init(bytes: bytes)
                    let mnemonicString = String(data: decryptedData, encoding: .utf8)
                    self.mnemonic = mnemonicString?.components(separatedBy: " ")
                    log.info("Unlock successful")
                    self.state = .unlocked
                    
                }
                else
                {
                    throw MeowKeyStoreError.unlockError

                }

            }
    
            
        } catch {
            throw MeowKeyStoreError.unlockError
        }

        try self.initWallet()

        if let address = self.defaultETHAddress() {
            DispatchQueue.main.async {
                self.saveCachedAddress(address: address)
                MeowManager.shared.updateWalletAddress(address: address)
            }
        }

    }
    
    func initWallet() throws {
        let seed = Mnemonic.createSeed(mnemonic: self.mnemonic!)
        self.wallet = try Wallet(seed: seed, network: MeowConfig.ETH.network)

    }
    
    func lock() {

        self.mnemonic = nil
        self.state = .locked
    }
    
    func defaultETHAddress() -> String? {
        
        // if address cache is present
        if let address = self.addressCache {
            log.debug("From cache: Current ETH Address --- " + address)
            return address
        }
        
        // if no address cache, and the wallet is locked. we have no way
        // to reveal the address unless user unlock it.
        
        if (self.state != .unlocked) {
            return nil
        }
        log.debug("From generating: Current ETH Address --- " + wallet!.generateAddress())
        return wallet?.generateAddress()
    }
    
    func signTransaction(tx: RawTransaction) throws -> String  {
        
        if (self.state != .unlocked) {
            throw MeowKeyStoreError.notAuthorized
        }
        
        let signedTx = try self.wallet!.sign(rawTransaction: tx)
        
        return signedTx
        
    }
    
    
    func saveCachedAddress(address: String) {
        try? address.write(to: URL(fileURLWithPath: MeowConfig.KeyStore.keyStoreAddressCacheFilePath), atomically: true, encoding: .utf8)
    }
    
    
    
    
}
