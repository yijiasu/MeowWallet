//
//  MeowAlertViewController.swift
//  ARLandOne
//
//  Created by Su Yijia on 6/6/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MeowAlertViewButton: UIButton {
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.gray.withAlphaComponent(0.1) : UIColor.clear
        }
    }
}

struct MeowAlertViewButtonItem {
    
    var title: String
    var action: (() -> Void)
    
}

class MeowAlertViewController: UIViewController {

    private var stackView: UIStackView!
    
    var _buttons: [MeowAlertViewButtonItem]!
    
    var buttons: [MeowAlertViewButtonItem] {
        get {
            return _buttons
        }
        
        set {
            _buttons = newValue
            updateButtonView()
        }
    }
    
    var contentView: UIView {
        get { return self.view }
//        get { return (self.view as! UIVisualEffectView).contentView }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
    }

    override func loadView() {

//        let blurEffect = UIBlurEffect(style: .light)
//        let effectView = UIVisualEffectView.init(effect: blurEffect)
//        effectView.backgroundColor = UIColor.init(rgb: 0xF7F7F7)
//
//        self.view = effectView
        
        let view = UIView()
        view.backgroundColor = UIColor.init(rgb: 0xF7F7F7)

        self.view = view
    }
    
    private func setupStackView() {
        
        stackView = UIStackView.init()
        self.contentView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        stackView.axis = .horizontal
        stackView.alignment = .fill
    }
    
    private func updateButtonView() {
        
        // 1. remove old buttons
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
        }
        
        for (index, buttonItem) in _buttons.enumerated() {
            
            let buttonView = MeowAlertViewButton.init(type: .custom)
            buttonView.setTitle(buttonItem.title, for: .normal)
            buttonView.setTitleColor(UIView().tintColor, for: .normal)
            buttonView.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
            buttonView.tag = index
            buttonView.addTarget(self, action: #selector(onSelectButton(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(buttonView)
            buttonView.snp.makeConstraints { (make) in
                make.height.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(1.0 / Float(_buttons.count))
            }
            
            // add top border
            let topBorderView = UIView()
            buttonView.addSubview(topBorderView)
            topBorderView.snp.makeConstraints { (make) in
                make.height.equalTo(0.5)
                make.left.right.top.equalToSuperview()
            }
            topBorderView.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
            
            // if not last button, add right border
            if (index != _buttons.count - 1) {
                let splitBorderView = UIView()
                buttonView.addSubview(splitBorderView)
                splitBorderView.snp.makeConstraints { (make) in
                    make.top.bottom.right.equalToSuperview()
                    make.width.equalTo(0.5)
                }
                splitBorderView.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
            }
            
        }
        
        
    }
    
    @objc func onSelectButton(_ button: UIButton) {
        _buttons[button.tag].action()
    }
    
}


extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer();
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x:0, y:self.frame.height - thickness, width:self.frame.width, height:thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x:0, y:0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x:self.frame.width - thickness, y: 0, width: thickness, height:self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
}
