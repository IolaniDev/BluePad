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
    
    var refreshTimer: NSTimer? = nil
    var waitTimer: NSTimer? = nil //puts a delay on refresh actions to allow connection states to update
    
    @IBOutlet weak var BLEDevicesTableView: UITableView!
    
    @IBOutlet weak var SelectedBLEDevice: UILabel!
    
    @IBOutlet weak var CurrentConnectionLabel: UILabel!
    
    @IBOutlet weak var ConnectButton: UIButton!
    
    @IBAction func ConnectButtonPressed(sender: AnyObject) {
        self.connectCurrentDevice()
        refreshVisuals()
        if let peripheral = CentralManager.connectedPeripheral {
            CurrentConnectionLabel.text = "Currently connected to: \(peripheral.name)"
        }

    }
    
    @IBAction func DisconnectButtonPressed(sender: AnyObject) {
        CentralManager.disconnect()
        refreshWithWait()
    }
    
    @IBAction func RefreshButtonPressed(sender: AnyObject) {
        refreshVisuals()
    }
    
    func startTimer()
    {
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: Selector("refreshVisuals"), userInfo: nil, repeats: true)
    }
    
    func refreshWithWait()
    {
        waitTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("refreshVisuals"), userInfo: nil, repeats: false)
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
            if peripheral.state == CBPeripheralState.Connected {
                CurrentConnectionLabel.text = "Currently connected to: \(peripheral.name)"
                return
            }
        }
        CurrentConnectionLabel.text = "No active connection"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CentralManager.startScanning()
        
        self.BLEDevicesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CentralManager.BLEPeripheralList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = self.BLEDevicesTableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        //cell.textLabel?.text = "\(CentralManager.BLEPeripheralList[indexPath.row].name) \(CentralManager.BLEPeripheralList[indexPath.row].RSSI)"
        
        //Apple broke RSSI
        
        cell.textLabel?.text = CentralManager.BLEPeripheralList[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        refreshVisuals()
        self.SelectedBLEDevice.text = CentralManager.BLEPeripheralList[indexPath.row].name
    }
    
    func connectCurrentDevice() {
        if (SelectedBLEDevice.text != "No device selected") {
            CentralManager.connectToPeripheralWithName(SelectedBLEDevice.text!)
        }
    }
    
}

