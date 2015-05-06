//
//  JoystickControlsViewController.swift
//  BluePad2.0
//
//  Created by student on 4/27/15.
//  Copyright (c) 2015 Iolani. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class JoystickControlsViewController: UIViewController, AnalogStickProtocol {
    
    var timer: NSTimer? = nil
    
    let analogStick : AnalogStick = AnalogStick()
    
    // Joystick parameters //
    let bgDiametr: CGFloat = 120
    let thumbDiametr: CGFloat = 60
    let joysticksRadius: CGFloat = 60
    moveAnalogStick.bgNodeDiametr = 120
    moveAnalogStick.thumbNodeDiametr = thumbDiametr
    moveAnalogStick.position = CGPointMake(joysticksRadius + 15, joysticksRadius + 15)
    moveAnalogStick.delagate = self
    self.addChild(moveAnalogStick)

    func startTimer()
    {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("processDirection"), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        startTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
}