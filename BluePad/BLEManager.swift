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
    
    private var BLECentralManager : CBCentralManager?
    
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
        let centralQueue = dispatch_queue_create("com.raywenderlich", DISPATCH_QUEUE_SERIAL)
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
        BLECentralManager?.scanForPeripheralsWithServices([BLEServiceUUID], options: nil)
    }
    
    func stopScanning() {
        BLECentralManager?.stopScan()
    }
    
    
    func isPeripheralInList(peripheralInput: CBPeripheral) -> Bool {
        let peripheralName = peripheralInput.name
        
        for peripheral : CBPeripheral in BLEPeripheralList {
            if (peripheral.name == peripheralName) {
                return true
            }
        }
        
        return false
    }
    
    // Returns whether or not it could successfully find the peripheral
    func connectToPeripheralWithName(peripheralName: String) -> Bool {
        for peripheral : CBPeripheral in BLEPeripheralList {
            if (peripheral.name == peripheralName) {
                self.connectToPeripheral(peripheral)
            }
        }
        
        return false
    }
    
    func connectToPeripheral(peripheral: CBPeripheral) {
        disconnect()
        connectedPeripheral = peripheral
        BLECentralManager?.connectPeripheral(peripheral, options: nil)
    }
    
    // Discovery //
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        //Checking if it's already connected is untested and experimental; may make stuff break!
        if (!isPeripheralInList(peripheral) && peripheral.state != CBPeripheralState.Connected) {
            BLEPeripheralList.append(peripheral)
            print("Found a peripheral named \(peripheral.name)")
            //peripheral.readRSSI()
            //Apple's RSSI system doesn't work! D:
        }
    }
    
    // Connection //
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        //What do we do when we connect to a peripheral?
        stopScanning()
        
        if (connectedPeripheral == peripheral) {
            connectedService = BLEService(initWithPeripheral: peripheral)
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        //What do we do when we disconnect from a peripheral?
        reset()
        startScanning()
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        //What do we do when we fail to connect to a peripheral?
    }
    
    // Central Manager states //
    func centralManagerDidUpdateState(central: CBCentralManager) {
        //How do we handle various central manager states?
        if let manager = BLECentralManager {
            switch (manager.state) {
                case CBCentralManagerState.PoweredOff:
                    stopScanning()
                    reset()
                    break
            
                case CBCentralManagerState.Unauthorized:
                    break
            
                case CBCentralManagerState.Unknown:
                    break
            
                case CBCentralManagerState.PoweredOn:
                    startScanning()
                    break
            
                case CBCentralManagerState.Resetting:
                    stopScanning()
                    reset()
                    break
            
                case CBCentralManagerState.Unsupported:
                    break
            
                default:
                    break
            }
        }
    }
}