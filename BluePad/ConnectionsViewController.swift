//
//  ConnectionsViewController.swift
//  BluePad2.0
//
//  Created by Aidan Swope on 4/22/15.
//  Copyright (c) 2015 Iolani. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConnectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var refreshTimer: Timer? = nil
    var waitTimer: Timer? = nil //puts a delay on refresh actions to allow connection states to update
    
    @IBOutlet weak var BLEDevicesTableView: UITableView!
    
    @IBOutlet weak var SelectedBLEDevice: UILabel!
    
    @IBOutlet weak var CurrentConnectionLabel: UILabel!
    
    @IBOutlet weak var ConnectButton: UIButton!
    
    @IBAction func ConnectButtonPressed(_ sender: AnyObject) {
        self.connectCurrentDevice()
        refreshVisuals()
        if let peripheral = CentralManager.connectedPeripheral {
            CurrentConnectionLabel.text = "Currently connected to: \(String(describing: peripheral.name))"
        }

    }
    
    @IBAction func DisconnectButtonPressed(_ sender: AnyObject) {
        CentralManager.disconnect()
        refreshWithWait()
    }
    
    @IBAction func RefreshButtonPressed(_ sender: AnyObject) {
        refreshVisuals()
    }
    
    func startTimer()
    {
        refreshTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(ConnectionsViewController.refreshVisuals), userInfo: nil, repeats: true)
    }
    
    func refreshWithWait()
    {
        waitTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ConnectionsViewController.refreshVisuals), userInfo: nil, repeats: false)
    }
    
    func refreshData()
    {
        CentralManager.BLEPeripheralList = []
        refreshWithWait()
    }
    
    func refreshVisuals()
    {
        BLEDevicesTableView.reloadData()
        if let peripheral = CentralManager.connectedPeripheral {
            if peripheral.state == CBPeripheralState.connected {
                CurrentConnectionLabel.text = "Currently connected to: \(String(describing: peripheral.name))"
                return
            }
        }
        CurrentConnectionLabel.text = "No active connection"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CentralManager.startScanning()
        
        self.BLEDevicesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        SelectedBLEDevice.adjustsFontSizeToFitWidth = true
        CurrentConnectionLabel.adjustsFontSizeToFitWidth = true
        
        BLEDevicesTableView.reloadData()
        
        startTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Table view functions //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CentralManager.BLEPeripheralList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.BLEDevicesTableView.dequeueReusableCell(withIdentifier: "cell")!
        
        //cell.textLabel?.text = "\(CentralManager.BLEPeripheralList[indexPath.row].name) \(CentralManager.BLEPeripheralList[indexPath.row].RSSI)"
        
        //Apple broke RSSI
        
        cell.textLabel?.text = CentralManager.BLEPeripheralList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        refreshVisuals()
        self.SelectedBLEDevice.text = CentralManager.BLEPeripheralList[indexPath.row].name
    }
    
    func connectCurrentDevice() {
        if (SelectedBLEDevice.text != "No device selected") {
            _ = CentralManager.connectToPeripheralWithName(SelectedBLEDevice.text!)
        }
    }
    
}

