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
        let dff = DateFormatter()
        dff.dateFormat = "yyyyMMdd_HHmm"
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
    
    let detector = ZipperDetector()
    var updateCounter = 0
    var statusLabel: UILabel!
    var debugLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zipper.delegate = self
        zipper.startMonitoring()
        documentInteractionController.delegate = self
        
        setupStatusLabel()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupStatusLabel() {
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.boldSystemFont(ofSize: 24)
        statusLabel.text = "Waiting for data..."
        self.view.addSubview(statusLabel)

        debugLabel = UILabel()
        debugLabel.translatesAutoresizingMaskIntoConstraints = false
        debugLabel.textAlignment = .center
        debugLabel.font = UIFont.systemFont(ofSize: 12)
        debugLabel.numberOfLines = 0
        self.view.addSubview(debugLabel)

        // Basic layout (centered, bottom)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                statusLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                statusLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100),
                statusLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -40),

                debugLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
                debugLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                debugLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -40)
            ])
        } else {
            // Fallback for older iOS if needed, but assuming iOS 9+ for anchors
            statusLabel.frame = CGRect(x: 20, y: self.view.bounds.height - 150, width: self.view.bounds.width - 40, height: 50)
            debugLabel.frame = CGRect(x: 20, y: self.view.bounds.height - 100, width: self.view.bounds.width - 40, height: 80)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateMagneticField() {
        magneticAmplitude?.text = String(format: "%.2f", zipper.magneticAmplitude)
        zipperSamples.add(value: zipper.measurementRow)
        numberOfSamples.text = zipperSamples.count.description
        // print("magnitude updated at  \(zipper.magneticSampleTime)")
        
        updateCounter += 1
        if updateCounter % 30 == 0 { // Every ~1 second
            performDetection()
        }
    }

    func performDetection() {
        // magneticAmplitude is at index 1 in measurementRow: [tm, ma, mx, my, mz, ...]
        // We need to extract this column.
        let magneticMagnitudes = zipperSamples.getColumn(index: 1)

        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.detector.detect(samples: magneticMagnitudes)

            DispatchQueue.main.async {
                if result.fundamentalFreq == 0 {
                    self.statusLabel.text = "Insufficient Data"
                    self.statusLabel.textColor = .gray
                    self.debugLabel.text = "Collecting samples..."
                } else {
                    if result.isOpen {
                        self.statusLabel.text = "ZIPPER OPEN!"
                        self.statusLabel.textColor = .red
                    } else {
                        self.statusLabel.text = "Zipper Closed"
                        self.statusLabel.textColor = .green
                    }
                    self.debugLabel.text = String(format: "Freq: %.1fHz, Ratio: %.2f", result.fundamentalFreq, result.ratio)
                }
            }
        }
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
