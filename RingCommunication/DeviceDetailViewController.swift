//
//  DeviceDetailViewController.swift
//  RingCommunication
//
//  Created by Keval Patel on 6/17/22.
//

import UIKit
import CoreBluetooth

class DeviceDetailViewController: UIViewController {

    @IBOutlet weak var reconnectButton: UIButton!
    
    var peripheral: CBPeripheral?
    var centralManager: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: .global())
        guard let peripheral = peripheral else { return }
        print("\(peripheral)")
        print("UUID \(peripheral.identifier.uuidString)")
        peripheral.delegate = self
        let cbuudid = CBUUID(string: peripheral.identifier.uuidString)
        peripheral.discoverServices(nil)
    }
    
    @IBAction func reconnectButtonTapped( sender: Any) {
        print("Reconnect")
        guard let peripheral = peripheral else { return }
        let cbuudid = CBUUID(string: peripheral.identifier.uuidString)
        peripheral.discoverServices([cbuudid])
    }
}

extension DeviceDetailViewController : CBPeripheralDelegate, CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState( _ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
        @unknown default:
            fatalError()
        }
    }

    // On detecting a device, will get a call back to "didDiscoverPeripheral" delegate method. Then establish a connection with detected BLE device
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Services error: \(error)")
            return
        }
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services, peripheralServices != nil else { return }
        print("🚀 Peripheral Services: \(peripheralServices)")
        for service in peripheralServices {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // Once we get the required characteristics detail, we need to subscribe to it, which lets the peripheral know we want the data it contains
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("🚀 didDiscoverCharacteristicsFor Called")
        if let error = error {
            print("Characteristics error: \(error)")
            return
        }
        guard let serviceCharacteristics = service.characteristics, serviceCharacteristics != nil else { return }
        print("🚀 serviceCharacteristics: \(serviceCharacteristics)")
        for characteristic in serviceCharacteristics {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("🚀 didUpdateNotificationStateFor Called")
        if let error = error {
            print("Characteristics error: \(error)")
            return
        }
        
        if characteristic != nil {
            print("Characteristic \(characteristic)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("🚀 didUpdateValueFor Called")
        if let error = error {
            print("didUpdateValueFor error: \(error)")
        }
        
        if characteristic.value != nil {
            print("🍀 Characteristic Value\(characteristic.value?.description)")
        }
    }
    
}
