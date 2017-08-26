//
//  BLEService.swift
//  BluePad2.0
//
//  Created by Aidan Swope on 4/23/15.
//  Copyright (c) 2015 Iolani. All rights reserved.
//  Templated from BTService.swift by Owen L Brown

import Foundation
import CoreBluetooth

let BLEServiceUUID = CBUUID(string: "FFE0")
let PositionCharUUID = CBUUID(string: "FFE1")
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BLEService: NSObject, CBPeripheralDelegate {
    var BLEPeripheral : CBPeripheral?
    var positionCharacteristic : CBCharacteristic?
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        
        self.BLEPeripheral = peripheral
        self.BLEPeripheral!.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    func reset() {
        BLEPeripheral = nil
    }
    
    func startDiscoveringServices() {
        self.BLEPeripheral?.discoverServices([BLEServiceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let uuidsForBTService: [CBUUID] = [PositionCharUUID]
        
        if (peripheral != self.BLEPeripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
            // No Services
            return
        }
        
        for service in peripheral.services! {
            if service.uuid == BLEServiceUUID {
                peripheral.discoverCharacteristics(uuidsForBTService, for: service )
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (peripheral != self.BLEPeripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        for characteristic in service.characteristics! {
            if characteristic.uuid == PositionCharUUID {
                self.positionCharacteristic = (characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
                
                // Send notification that Bluetooth is connected and all required characteristics are discovered
                self.sendBTServiceNotificationWithIsBluetoothConnected(true)
            }
        }
    }
    
    // Mark: - Private
    
    func writePosition(_ position: Character) {
        // See if characteristic has been discovered before writing to it
        if self.positionCharacteristic == nil {
            return
        }
        
        // Need a mutable var to pass to writeValue function
        var positionValue = position
        let data = Data(bytes: &positionValue, count: MemoryLayout<UInt8>.size)
        self.BLEPeripheral?.writeValue(data, for: self.positionCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    func writeGyro(_ gyroString: String) {
        // See if characteristic has been discovered before writing to it
        if self.positionCharacteristic == nil {
            return
        }
        
        // Need a mutable var to pass to writeValue function
        _ = gyroString
        let data = gyroString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        self.BLEPeripheral?.writeValue(data!, for: self.positionCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
    }
    
}
