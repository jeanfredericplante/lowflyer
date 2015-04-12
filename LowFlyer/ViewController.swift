//
//  ViewController.swift
//  LowFlyer
//
//  Created by Jean Frederic Plante on 3/29/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ZipperUpdateDelegate {
    
    enum StateSegments: Int {
        case Open = 0
        case Close = 1
    }

    
    @IBOutlet weak var magneticAmplitude: UILabel!
    
    @IBOutlet weak var numberOfSamples: UILabel!
     struct Constants {
        static let maxSamples = 1024
    }
    
    @IBAction func emailData(sender: AnyObject) {
        var filename: String = "samples.csv"
        if let openClose = StateSegments(rawValue: zipperState.selectedSegmentIndex) {
            switch openClose {
            case .Open:
                filename = "samples_open.csv"
            case .Close:
                filename = "samples_close.csv"
            }
        }
        emailCSVData(filename)
    }
        
    @IBAction func clearData(sender: AnyObject) {
        zipperSamples.clear()
    }
    
    @IBOutlet weak var zipperState: UISegmentedControl!
    
    let mailVC = EmailComposer()
    let zipper = ZipperMeter()
    var zipperSamples = MeasurementSamples(maxSamples: Constants.maxSamples)
   

    override func viewDidLoad() {
        super.viewDidLoad()
        zipper.delegate = self
        zipper.startMonitoring()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateMagneticField() {
        magneticAmplitude?.text = zipper.magneticAmplitude.description
        zipperSamples.add(zipper.measurementRow)
        numberOfSamples.text = zipperSamples.count.description
        println("magnitude updated at  \(zipper.magneticSampleTime)")
        
    }
    
    func didUpdateAccelerationField() {
        println("Acc updated at \(zipper.accelerationSampleTime)")
    }
    
    func emailCSVData(filename: String) {
        var csv = zipperSamples.samplesAsCSVString()
        var error: NSError? = nil
        if let filepath = filePath(filename) as? String {
            csv.writeToFile(filepath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
            println("data saved to file")
            
            if error == nil {
                let configuredMailVC = mailVC.configuredMailComposeViewController()
                configuredMailVC.addAttachmentData(NSData.dataWithContentsOfMappedFile(filepath) as?
                    NSData , mimeType: "text/csv", fileName: filename)
                presentViewController(configuredMailVC, animated: true, completion: nil)
            }
        }
        
    }
    
    func filePath(filename: String) -> NSString? {
        return NSTemporaryDirectory().stringByAppendingString("\(filename)")
    }



}

