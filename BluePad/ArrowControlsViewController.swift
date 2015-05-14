//
//  ControlsViewController.swift
//  BluePad2.0
//
//  Created by Aidan Swope on 4/22/15.
//  Copyright (c) 2015 Iolani. All rights reserved.
//

import UIKit
import CoreBluetooth

class ArrowControlsViewController: UIViewController {
    
    var timer: NSTimer? = nil
    
    @IBOutlet weak var UpArrowButton: UIButton!
    
    @IBOutlet weak var RightArrowButton: UIButton!
    
    @IBOutlet weak var DownArrowButton: UIButton!
    
    @IBOutlet weak var LeftArrowButton: UIButton!
    
    @IBOutlet weak var CurrentDirectionLabel: UILabel!
    
    @IBOutlet weak var CurrentConnectionLabel: UILabel!
    
    func processDirection() {
        if UpArrowButton.state == .Highlighted {
            CurrentDirectionLabel.text = "Up"
            sendDirection(Character("U"))
        } else if DownArrowButton.state == .Highlighted {
            CurrentDirectionLabel.text = "Down"
            sendDirection(Character("D"))
        } else if LeftArrowButton.state == .Highlighted {
            CurrentDirectionLabel.text = "Left"
            sendDirection(Character("L"))
        } else if RightArrowButton.state == .Highlighted {
            CurrentDirectionLabel.text = "Right"
            sendDirection(Character("R"))
        } else {
            CurrentDirectionLabel.text = "Stop"
            sendDirection(Character("C"))
        }
    }
    
    func timerTick() {
        processDirection()
        refreshVisuals()
    }
    
    func refreshVisuals()
    {
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
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("timerTick"), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentDirectionLabel.adjustsFontSizeToFitWidth = true
        
        UpArrowButton.setImage(UIImage(named: "arrow_up"), forState: .Normal)
        DownArrowButton.setImage(UIImage(named: "arrow_down"), forState: .Normal)
        LeftArrowButton.setImage(UIImage(named: "arrow_left"), forState: .Normal)
        RightArrowButton.setImage(UIImage(named: "arrow_right"), forState: .Normal)
        
        UpArrowButton.setImage(UIImage(named: "arrow_up_red.jpg"), forState: .Highlighted)
        DownArrowButton.setImage(UIImage(named: "arrow_down_red.jpg"), forState: .Highlighted)
        LeftArrowButton.setImage(UIImage(named: "arrow_left_red.jpg"), forState: .Highlighted)
        RightArrowButton.setImage(UIImage(named: "arrow_right_red.jpg"), forState: .Highlighted)
        
        CurrentConnectionLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidAppear(animated: Bool) {
        startTimer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
    
    func sendDirection(direction: Character) {
        if let service = CentralManager.connectedService {
            service.writePosition(direction)
        }
    }
}

