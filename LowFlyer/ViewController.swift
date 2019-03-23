//
//  ViewController.swift
//  LowFlyer
//
//  Created by Jean Frederic Plante on 3/29/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ZipperUpdateDelegate {
    let documentInteractionController = UIDocumentInteractionController()

    @IBOutlet weak var drawLetters: UISwitch!
    @IBOutlet weak var targetLetter: UITextField!
    
   
    @IBAction func editingEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    enum ZipperStateSegments: Int {
        case Open = 0
        case Close = 1
    }

    enum WalkingStateSegments: Int {
        case Walking = 0
        case Still = 1
    }
    
    @IBOutlet weak var magneticAmplitude: UILabel!
    
    @IBOutlet weak var numberOfSamples: UILabel!
     struct Constants {
        static let maxSamples = 16384
    }
    
    @IBAction func emailData(_ sender: Any) {
        var filename: String = ""
        if !drawLetters.isOn{
            if let openClose = ZipperStateSegments(rawValue: zipperState.selectedSegmentIndex), let walkingStill = WalkingStateSegments(rawValue: activityState.selectedSegmentIndex) {
                switch (openClose, walkingStill) {
                case (.Open,.Walking):
                    filename = "samples_open_walking"
                case (.Open,.Still):
                    filename = "samples_open_still"
                case (.Close,.Walking):
                    filename = "samples_closed_walking"
                case (.Close,.Still):
                    filename = "samples_closed_still"
                    
                }
                }
            
        } else {
            if let f = targetLetter.text {
                filename = f
            } else {
                filename = "default_letter"
            }
        }
        let dff = DateFormatter()
        dff.dateFormat = "yyyyMMdd_HHmmss"
        filename = dff.string(from: Date()) + "_" + filename + ".csv"
        
        saveCSVfile(filename: filename)
    }
    
    @IBAction func clearData(_ sender: Any) {
        zipperSamples.clear()
        
    }
 
    @IBOutlet weak var zipperState: UISegmentedControl!
    @IBOutlet weak var activityState: UISegmentedControl!
    
    let mailVC = EmailComposer()
    let zipper = ZipperMeter()
    var zipperSamples = MeasurementSamples(maxSamples: Constants.maxSamples)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zipper.delegate = self
        zipper.startMonitoring()
        documentInteractionController.delegate = self
        
        
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
    
    func saveCSVfile(filename: String) {
        let csv = zipperSamples.samplesAsCSVString()
        if let filepath = filePath(filename: filename) as URL? {
            do {
                try csv.write(to: filepath, atomically: true, encoding: String.Encoding.utf8)
                print("data saved to file")
                DispatchQueue.main.async {
                    self.share(url: (filepath as URL))
                }
            } catch {
                print("error writing to file")
            }
            
        }
    }
    
    func filePath(filename: String) -> URL? {
        if #available(iOS 10.0, *) {
            return FileManager.default.temporaryDirectory
                .appendingPathComponent(("\(filename)"))
        } else {
            return nil
        }
    }



}

extension ViewController {
    /// This function will set all the required properties, and then provide a preview for the document
    func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentOptionsMenu(from: view.frame, in: view, animated: true)

    }
    
}

extension ViewController: UIDocumentInteractionControllerDelegate {
    /// If presenting atop a navigation stack, provide the navigation controller in order to animate in a manner consistent with the rest of the platform
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navVC = self.navigationController else {
            return self
        }
        return navVC
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}
