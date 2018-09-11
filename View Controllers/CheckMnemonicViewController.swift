//
//  CheckMnemonicViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 26/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import EthereumKit

class CheckMnemonicViewController: MeowAlertViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!

    private let keystore = MeowKeyStore.shared
    
    private var correctAnswer : String!
    
    private var allWords : [String]!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Create Wallet"
        
        setupCollectionView()
        setupView()
        loadWords()
        setupButtons()

        
    }
    
    func setupView() {
        
        let textLabel = UILabel.init()
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(collectionView.snp.bottom).offset(12)
        }
        
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.text = "Tap all words that appear in your mnemonic words you just wrote down."

    }
    
    func setupCollectionView() {
        
        let viewLayout = UICollectionViewFlowLayout.init()
        viewLayout.estimatedItemSize = CGSize.init(width: 100, height: 30)

        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: viewLayout)
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(120)
        }
        collectionView.layer.borderColor = UIColor.init(rgb: 0x8E8E93).cgColor
        collectionView.layer.borderWidth = 0.5

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        collectionView.register(UINib.init(nibName: "MnemonicWordCell", bundle: nil), forCellWithReuseIdentifier: "MnemonicWordCell")

    }
    
    func loadWords() {
        if let words = try? keystore.getMnemonicString() {
            let originalWords = words.components(separatedBy: " ")
            
            let shuffleWords = Array(self.wordList.shuffled().prefix(4))
            let answerWords = originalWords.shuffled().prefix(6)
            
            self.correctAnswer = answerWords.sorted().joined(separator: " ")
            log.verbose("correctAnswer == " + self.correctAnswer)
            
            self.allWords = (shuffleWords + answerWords).shuffled()
        }
    }
    
    
    func setupButtons() {
        
        buttons = [
            MeowAlertViewButtonItem(title: "Next Step", action: {
                self.onNext()
            })
        ]
    }
    

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allWords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "MnemonicWordCell", for: indexPath) as! MnemonicWordCell
        cell.configureWithWord(self.allWords[indexPath.row])
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")
    }
    
    
    func onNext() {
        
//        self.navigationController?.pushViewController(SetPasscodeViewController(), animated: true)
//        return
        
        let indexes = self.collectionView.indexPathsForSelectedItems?.map({ (indexPath) -> String in
            return self.allWords[indexPath.row]
        })
        
        if let answer = indexes?.sorted().joined(separator: " ") {
            if answer == self.correctAnswer {
                self.navigationController?.pushViewController(SetPasscodeViewController(), animated: true)
//                self.performSegue(withIdentifier: "setPassCode", sender: nil)
            }
            else {
                MeowUtil.alert(message: "Incorrect answer. Please check your mnemonic list again.")
            }
        }

    }

    
}
