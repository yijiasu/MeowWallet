//
//  GasPricePushRow.swift
//  ARLandOne
//
//  Created by Su Yijia on 23/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import UIKit
import Eureka


public class GasPriceAdjustViewContoller: FormViewController, TypedRowControllerType {

    public var row: RowOf<Int>!
    public var onDismissCallback: ((UIViewController) -> Void)?
    
    
    override public func viewDidLoad() {
        
        
        super.viewDidLoad()
        form +++ Section("Gas Price")
            <<< LabelRow.init("PriceRow") { priceRow in
                priceRow.title = "Gas Price"
                priceRow.value = String.init(describing: self.row.value!) + " GWei"
                }.cellUpdate({ (cell, _) in
                    cell.detailTextLabel?.text = String(self.row.value!) + " GWei"
                })
            <<< SliderRow {
                $0.value = Float(row.value ?? 1)
                $0.minimumValue = 1
                $0.maximumValue = 50
                $0.shouldHideValue = true
                }.onChange({ row in
                    self.row.value = Int(row.value ?? 0)
                    self.updateGasPrice(gasPrice: self.row.value!)
                })

        form +++ Section()
            // TODO: To implement using api
            <<< LabelRow { row in
                row.title = "Suggested Gas Price"
                row.value = "10 GWei"
        }
    }
    
    func updateGasPrice(gasPrice: Int) {
        form.setValues([ "PriceRow" : gasPrice ])
        form.allSections.forEach { section in
            section.forEach({ row in
                row.updateCell()
            })
        }
    }
    
}

public final class GasPriceRow: OptionsRow<PushSelectorCell<Int>>, PresenterRowType, RowType {
    
    public var presentationMode: PresentationMode<GasPriceAdjustViewContoller>?
    
    public var onPresentCallback: ((FormViewController, GasPriceAdjustViewContoller) -> Void)?
    
    public typealias PresentedControllerType = GasPriceAdjustViewContoller
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback {
            return GasPriceAdjustViewContoller()
            }, onDismiss: { vc in
                 _ = vc.navigationController?.popViewController(animated: true)
        })
        
        displayValueFor = {
            guard let value = $0 else { return "" }
            return String(value) + " GWei"
        }
        
    }
    
    
    open override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }

    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresentedControllerType else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }

}
