//
//  AddressScannerCell.swift
//  ARLandOne
//
//  Created by Su Yijia on 24/5/2018.
//  Copyright © 2018 Su Yijia. All rights reserved.
//

import Foundation
import Eureka

final class AddressScannerCell: Cell<String>, CellType {

    var scannedAddressCallback: ((String) -> Void)?

    @IBOutlet weak var cameraView: UIView!

    var scanner : QRCodeReader!
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        self.selectionStyle = .none
        
        self.height = {
            return 150
        }
        
        setupCamera()
        self.backgroundView = UIView()
    }

    func setupCamera() {
        
        self.scanner = QRCodeReader()

        self.cameraView.backgroundColor = UIColor.clear

        let previewLayer = self.scanner.previewLayer
        previewLayer.frame = self.cameraView.layer.bounds
        previewLayer.contentsScale = 2.0
        
        self.cameraView.layer.insertSublayer(previewLayer, at: 0)

        self.scanner.startScanning()
        self.scanner.didFindCode = { result in
            if let callback = self.scannedAddressCallback {
                callback(result.value)
            }
        }
    }

}

final class AddressScannerRow: Row<AddressScannerCell>, RowType {

    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<AddressScannerCell>(nibName: "AddressScannerCell")
    }
    
    func onScannedAddress(_ callback: @escaping (_ address: String) -> Void) {
        
        cell.scannedAddressCallback = callback
    }
    
    func startScan()  {
        cell.scanner.startScanning()
    }

    func stopScan()  {
        cell.scanner.stopScanning()
    }

}
