//
//  ViewController.swift
//  LowFlyer
//
//  Created by Jean Frederic Plante on 3/29/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MagnetoUpdateDelegate {
        
    @IBOutlet weak var magneticAmplitude: UILabel!
    
    let magneto = MagnetoMeter()

    override func viewDidLoad() {
        super.viewDidLoad()
        magneto.delegate = self
        magneto.startMonitoring()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateMagneticField() {
        magneticAmplitude?.text = magneto.magnitude.description
        println("magnitude \(magneto.magnitude.description)")
        
    }


}

