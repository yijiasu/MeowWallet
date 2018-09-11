//
//  MnemonicWordCell.swift
//  ARLandOne
//
//  Created by Su Yijia on 26/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit

class MnemonicWordCell: UICollectionViewCell {
    
    @IBOutlet weak var wordLabel: UILabel!
    var isHeightCalculated: Bool = false

    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIView().tintColor : UIColor.init(rgb: 0xECEEF1)
            self.wordLabel.textColor = isSelected ? UIColor.white : UIColor.black
        }
    }

    
    func configureWithWord(_ word: String) {
        
        self.wordLabel.text = word
        self.isSelected = false
        self.layer.cornerRadius = 2
        self.layoutSubviews()
        
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let size: CGSize = self.wordLabel.text!.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
        layoutAttributes.frame = CGRect.init(origin: layoutAttributes.frame.origin, size: CGSize.init(width: size.width + 18, height: size.height + 8))
        return layoutAttributes
//        layoutAttributes.frame = CGSize
    }

    
}
