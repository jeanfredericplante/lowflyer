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
    
    @IBAction func emailData(_ sender: Any) {
        var filename: String = "samples.csv"
        if let openClose = StateSegments(rawValue: zipperState.selectedSegmentIndex) {
            switch openClose {
            case .Open:
                filename = "samples_open.csv"
            case .Close:
                filename = "samples_close.csv"
            }
        }
        emailCSVData(filename: filename)
    }
        
    @IBAction func clearData(_ sender: Any) {
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
        zipperSamples.add(value: zipper.measurementRow)
        numberOfSamples.text = zipperSamples.count.description
        print("magnitude updated at  \(zipper.magneticSampleTime)")
        
    }
    
    func didUpdateAccelerationField() {
        print("Acc updated at \(zipper.accelerationSampleTime)")
    }
    
    func emailCSVData(filename: String) {
        let csv = zipperSamples.samplesAsCSVString()
        if let filepath = filePath(filename: filename) as String? {
            do {
                try csv.write(toFile: filepath, atomically: true, encoding: String.Encoding.utf8)
                print("data saved to file")
                let configuredMailVC = mailVC.configuredMailComposeViewController()
                configuredMailVC.addAttachmentData(NSData.dataWithContentsOfMappedFile(filepath) as?
                    NSData as! Data , mimeType: "text/csv", fileName: filename)
                present(configuredMailVC, animated: true, completion: nil)
            } catch {
               print("error writing to file")
            }
        }
        
    }
    
    func filePath(filename: String) -> NSString? {
        return NSTemporaryDirectory().appendingFormat("\(filename)") as NSString
    }



}

