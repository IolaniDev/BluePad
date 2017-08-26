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
    
    var timer: Timer? = nil
    
    @IBOutlet weak var UpArrowButton: UIButton!
    
    @IBOutlet weak var RightArrowButton: UIButton!
    
    @IBOutlet weak var DownArrowButton: UIButton!
    
    @IBOutlet weak var LeftArrowButton: UIButton!
    
    @IBOutlet weak var CurrentDirectionLabel: UILabel!
    
    @IBOutlet weak var CurrentConnectionLabel: UILabel!
    
    func processDirection() {
        if UpArrowButton.state == .highlighted {
            CurrentDirectionLabel.text = "Up"
            sendDirection(Character("U"))
        } else if DownArrowButton.state == .highlighted {
            CurrentDirectionLabel.text = "Down"
            sendDirection(Character("D"))
        } else if LeftArrowButton.state == .highlighted {
            CurrentDirectionLabel.text = "Left"
            sendDirection(Character("L"))
        } else if RightArrowButton.state == .highlighted {
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
            if peripheral.state == CBPeripheralState.connected {
                CurrentConnectionLabel.text = "Currently connected to: \(String(describing: peripheral.name))"
                return
            }
        }
        CurrentConnectionLabel.text = "No active connection"
    }
    
    func startTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(ArrowControlsViewController.timerTick), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentDirectionLabel.adjustsFontSizeToFitWidth = true
        
        UpArrowButton.setImage(UIImage(named: "arrow_up"), for: UIControlState())
        DownArrowButton.setImage(UIImage(named: "arrow_down"), for: UIControlState())
        LeftArrowButton.setImage(UIImage(named: "arrow_left"), for: UIControlState())
        RightArrowButton.setImage(UIImage(named: "arrow_right"), for: UIControlState())
        
        UpArrowButton.setImage(UIImage(named: "arrow_up_red.jpg"), for: .highlighted)
        DownArrowButton.setImage(UIImage(named: "arrow_down_red.jpg"), for: .highlighted)
        LeftArrowButton.setImage(UIImage(named: "arrow_left_red.jpg"), for: .highlighted)
        RightArrowButton.setImage(UIImage(named: "arrow_right_red.jpg"), for: .highlighted)
        
        CurrentConnectionLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
    
    func sendDirection(_ direction: Character) {
        if let service = CentralManager.connectedService {
            service.writePosition(direction)
        }
    }
}

