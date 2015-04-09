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
    
    @IBOutlet weak var numberOfSamples: UILabel!
     struct Constants {
        static let maxSamples = 1000
    }
    
    @IBAction func emailData(sender: AnyObject) {
        emailCSVData("magneto.csv")
    }
        
    let mailVC = EmailComposer()
    let magneto = MagnetoMeter()
    var magneticSamples = MeasurementSamples(maxSamples: Constants.maxSamples)

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
        magneticSamples.add(magneto.magnitude)
        numberOfSamples.text = magneticSamples.count.description
        println("magnitude \(magneto.magnitude.description)")
        
    }
    
    func emailCSVData(filename: String) {
        var csv = magneticSamples.samplesAsCSVString()
        var error: NSError? = nil
        if let filepath = filePath(filename) {
            csv.writeToFile(filepath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
            println("data saved to file")
            
            if error == nil {
                let configuredMailVC = mailVC.configuredMailComposeViewController()
                configuredMailVC.addAttachmentData(NSData.dataWithContentsOfMappedFile(filepath) as NSData , mimeType: "text/csv", fileName: filename)
                presentViewController(configuredMailVC, animated: true, completion: nil)
            }
        }
        
    }
    
    func filePath(filename: String) -> NSString? {
        return NSTemporaryDirectory().stringByAppendingString("\(filename)")
    }



}

