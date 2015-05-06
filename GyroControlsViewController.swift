//
//  GyroControlsViewController.swift
//  BluePad2.0
//
//  Created by student on 5/1/15.
//  Copyright (c) 2015 Iolani. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import CoreBluetooth

let motionManager = CMMotionManager()

class GyroControlsViewController: UIViewController {
    
    @IBOutlet weak var CurrentConnectionLabel: UILabel!
    
    @IBOutlet weak var GoButton: UIButton!
    
    var timer: NSTimer? = nil
    
    func processMovement(x: Double, y: Double) {
        //Positive x = right tilt
        //Positive y = forward tile
        
        var toWrite = String()
        
        if GoButton.state == .Highlighted {
            toWrite = "CM,"
            toWrite += String(format: "%.1f", y)
            toWrite += ","
            toWrite += String(format: "%.1f", x)
        } else {
            toWrite = "CS"
        }
        
        toWrite += ";"
        
        if let service = CentralManager.connectedService {
            service.writeGyro(toWrite)
            //service.writePosition(Character("C"))
        }
        
        println(toWrite);
        
    }
    
    func refreshVisuals() {
        if let peripheral = CentralManager.connectedPeripheral {
            if peripheral.state == CBPeripheralState.Connected {
                CurrentConnectionLabel.text = "Currently connected to: \(peripheral.name)"
                return
            }
        }
        CurrentConnectionLabel.text = "No active connection"
    }
    
    func startTimer()
    {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("refreshVisuals"), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        motionManager.deviceMotionUpdateInterval = 0.05
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
            [weak self] (data: CMDeviceMotion!, error: NSError!) in
            
            //Right turn is negative around y axis, forward is negative around x axis
            let tiltHorizontal = -1 * data.attitude.pitch //Positive is right turn
            let tiltVertical   = -1 * data.attitude.roll //Positive is forward
            
            self!.processMovement(self!.radiansToDegrees(tiltHorizontal), y: self!.radiansToDegrees(tiltVertical))
            
        }
        
        startTimer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Stop sending data and stop the refresh timer //
        motionManager.stopDeviceMotionUpdates()
        timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
    
    func radiansToDegrees(radians : Double) -> Double {
        return 180 * radians / M_PI
    }
    
}
