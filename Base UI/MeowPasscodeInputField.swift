//
//  MeowPasscodeInputField.swift
//  ARLandOne
//
//  Created by Su Yijia on 8/6/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import UIKit


class PasscodeDigitTextField: UITextField {
    var isNextFocus: Bool = false
    var onBackspace: (() -> Void)?
    
    override var canBecomeFirstResponder: Bool {
        get { return isNextFocus }
    }
    
    override func resignFirstResponder() -> Bool {
        isNextFocus = false
        return super.resignFirstResponder()
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        if let onBackspace = self.onBackspace {
            onBackspace()
        }
    }
    
    
}



class MeowPasscodeInputField: UIView, UITextFieldDelegate {
    
    var onSubmitCode: ((_ code: String) -> Void)?
    var onEnterDigit: ((_ index: Int) -> Void)?
    var secure: Bool {
        get { return textFields.first!.isSecureTextEntry }
        set { textFields.forEach { $0.isSecureTextEntry = newValue } }
    }

    private let blankChar = "\u{200B}"
    private let digits = 4
    
    private var stackView: UIStackView!
    private var textFields: [PasscodeDigitTextField] = Array.init()
    private var focusIndex: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        
        stackView = UIStackView.init()
        addSubview(stackView)
        stackView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 15
        stackView.distribution = .equalCentering
        stackView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onStartInput)))
        
        
        for i in (1...digits) {
            
            let textField = PasscodeDigitTextField.init()
            textFields.append(textField)
            
            stackView.addArrangedSubview(textField)
            textField.snp.makeConstraints { (make) in
                make.height.width.equalTo(67)
            }
            
            textField.tag = i - 1
            textField.font = UIFont.boldSystemFont(ofSize: 28)
            textField.textAlignment = .center
            textField.layer.borderColor = UIColor.init(rgb: 0x8E8E93).cgColor
            textField.layer.borderWidth = 0.5
            textField.keyboardType = .numberPad
//            textField.text = blankChar
            textField.delegate = self
            textField.isUserInteractionEnabled = false
            
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textField.onBackspace = {
                self.movePreviousFocus()
            }
            
        }


    }
    
    @objc private func onStartInput() {
        for textField in textFields {
            textField.isUserInteractionEnabled = true
        }
        focusIndex = 0
        textFields.first!.isNextFocus = true
        textFields.first!.becomeFirstResponder()
    }
    
    private func moveNextFocus() {
        if focusIndex < textFields.count - 1 {
            focusIndex = focusIndex + 1
            textFields[focusIndex].isNextFocus = true
            textFields[focusIndex].becomeFirstResponder()
        }
        
        if let onEnterDigit = self.onEnterDigit {
            onEnterDigit(focusIndex)
        }
        updateCodeInput()
    }
    
    private func movePreviousFocus() {
        if focusIndex > 0 {
            focusIndex = focusIndex - 1
            textFields[focusIndex].isNextFocus = true
            textFields[focusIndex].becomeFirstResponder()
            textFields[focusIndex].text = nil
        }
//        restoreEmptyChar()
    }
    
//    private func restoreEmptyChar() {
//        for textField in textFields {
//            if textField.text?.count == 0 { textField.text = blankChar }
//        }
//    }
    
    private func clearAll() {
        for textField in textFields {
            textField.text = nil
            textField.isNextFocus = false
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 1 // Bool
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField.text?.count == 1 {
            moveNextFocus()
        }
        
    }
    
    func clear() {
        clearAll()
        onStartInput()
    }
    
    func updateCodeInput() {
        
        var code = String()
        for textField in textFields {
            if textField.text?.count != 0 {
                code = code + textField.text!.replacingOccurrences(of: blankChar, with: "")
            }
        }
        
        if code.count == 4 {
            if let onSubmitCode = self.onSubmitCode {
                onSubmitCode(code)
            }
        }
        
    }

}
