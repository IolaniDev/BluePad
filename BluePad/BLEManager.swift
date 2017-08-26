//
//  BLECentralManager.swift
//  BluePad2.0
//
//  Created by student on 4/22/15.
//  Copyright (c) 2015 Iolani. All rights reserved.
//

import Foundation
import CoreBluetooth

let CentralManager = BLEManager();

class BLEManager: NSObject, CBCentralManagerDelegate {
    
    fileprivate var BLECentralManager : CBCentralManager?
    
    var connectedPeripheral : CBPeripheral?
    
    var connectedService : BLEService? {
        didSet {
            if let service = self.connectedService {
                service.startDiscoveringServices()
            }
        }
    }
    
    var BLEPeripheralList : [CBPeripheral] = []
    
    override init() {
        super.init()
        let centralQueue = DispatchQueue(label: "com.raywenderlich", attributes: [])
        BLECentralManager = CBCentralManager(delegate: self, queue: centralQueue, options: nil)
    }
    
    func reset() {
        disconnect()
        BLEPeripheralList = []
    }
    
    func disconnect() {
        if connectedPeripheral != nil {
            BLECentralManager?.cancelPeripheralConnection(connectedPeripheral!)
        }
        connectedPeripheral = nil
        connectedService = nil
    }
    
    func startScanning() {
        BLECentralManager?.scanForPeripherals(withServices: [BLEServiceUUID], options: nil)
    }
    
    func stopScanning() {
        BLECentralManager?.stopScan()
    }
    
    
    func isPeripheralInList(_ peripheralInput: CBPeripheral) -> Bool {
        let peripheralName = peripheralInput.name
        
        for peripheral : CBPeripheral in BLEPeripheralList {
            if (peripheral.name == peripheralName) {
                return true
            }
        }
        
        return false
    }
    
    // Returns whether or not it could successfully find the peripheral
    func connectToPeripheralWithName(_ peripheralName: String) -> Bool {
        for peripheral : CBPeripheral in BLEPeripheralList {
            if (peripheral.name == peripheralName) {
                self.connectToPeripheral(peripheral)
            }
        }
        
        return false
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        disconnect()
        connectedPeripheral = peripheral
        BLECentralManager?.connect(peripheral, options: nil)
    }
    
    // Discovery //
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //Checking if it's already connected is untested and experimental; may make stuff break!
        if (!isPeripheralInList(peripheral) && peripheral.state != CBPeripheralState.connected) {
            BLEPeripheralList.append(peripheral)
            print("Found a peripheral named \(String(describing: peripheral.name))")
            //peripheral.readRSSI()
            //Apple's RSSI system doesn't work! D:
        }
    }
    
    // Connection //
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //What do we do when we connect to a peripheral?
        stopScanning()
        
        if (connectedPeripheral == peripheral) {
            connectedService = BLEService(initWithPeripheral: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //What do we do when we disconnect from a peripheral?
        reset()
        startScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //What do we do when we fail to connect to a peripheral?
    }
    
    // Central Manager states //
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //How do we handle various central manager states?
        if let manager = BLECentralManager {
            switch (manager.state) {
                case .poweredOff:
                    stopScanning()
                    reset()
                    break
            
                case .unauthorized:
                    break
            
                case .unknown:
                    break
            
                case .poweredOn:
                    startScanning()
                    break
            
                case .resetting:
                    stopScanning()
                    reset()
                    break
            
                case .unsupported:
                    break
            }
        }
    }
}
