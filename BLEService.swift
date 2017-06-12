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
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        let uuidsForBTService: [CBUUID] = [PositionCharUUID]
        
        if (peripheral != self.BLEPeripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services.count == 0)) {
            // No Services
            return
        }
        
        for service in peripheral.services {
            if service.UUID == BLEServiceUUID {
                peripheral.discoverCharacteristics(uuidsForBTService, forService: service as! CBService)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if (peripheral != self.BLEPeripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        for characteristic in service.characteristics {
            if characteristic.UUID == PositionCharUUID {
                self.positionCharacteristic = (characteristic as! CBCharacteristic)
                peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
                
                // Send notification that Bluetooth is connected and all required characteristics are discovered
                self.sendBTServiceNotificationWithIsBluetoothConnected(true)
            }
        }
    }
    
    // Mark: - Private
    
    func writePosition(position: Character) {
        // See if characteristic has been discovered before writing to it
        if self.positionCharacteristic == nil {
            return
        }
        
        // Need a mutable var to pass to writeValue function
        var positionValue = position
        let data = NSData(bytes: &positionValue, length: sizeof(UInt8))
        self.BLEPeripheral?.writeValue(data, forCharacteristic: self.positionCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    func writeGyro(gyroString: String) {
        // See if characteristic has been discovered before writing to it
        if self.positionCharacteristic == nil {
            return
        }
        
        // Need a mutable var to pass to writeValue function
        var value = gyroString
        let data = gyroString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        self.BLEPeripheral?.writeValue(data, forCharacteristic: self.positionCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
    }
    
}