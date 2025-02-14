//
//  PXDeviceViewController.swift
//  PluxAPI
//
//  Created by Marcelo Rodrigues on 03/06/16.
//  Copyright © 2016 Plux. All rights reserved.
//

import UIKit
import PluxAPI

class PXDeviceViewController: UIViewController, PXBioPluxManagerDelegate {

    // MARK:- Properties
    
    private let primaryColor = UIColor(red: 86/255, green: 98/255, blue: 112/255, alpha: 1)
    private let secondaryColor = UIColor(red: 224/255, green: 227/255, blue: 218/255, alpha: 1)
    
    private let device: PXDevice
    private let centralManager: PXBioPluxManager
    
    private var timer: NSTimer?
    private var secondsElapsed: Int
    
    @IBOutlet private weak var deviceUUIDTitleLabel: UILabel!
    @IBOutlet private weak var deviceUUIDValueLabel: UILabel!
    
    @IBOutlet private weak var stateTitleLabel: UILabel!
    @IBOutlet private weak var stateValueLabel: UILabel!
    
    @IBOutlet private weak var elapsedTimeTitleLabel: UILabel!
    @IBOutlet private weak var elapsedTimeValueLabel: UILabel!
    
    @IBOutlet private weak var outputTitleLabel: UILabel!
    @IBOutlet private weak var outputValueLabel: UILabel!
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var versionButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    // MARK:- Lifecycle
    
    init(device: PXDevice, centralManager: PXBioPluxManager) {

        self.device = device
        self.centralManager = centralManager
        self.secondsElapsed = 0
        
        super.init(nibName: String(PXDeviceViewController), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.centralManager.delegate = self
        
        self.configureNavigationBar()
        self.configureView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.centralManager.disconnectDevice(self.device)
    }
    
    private func configureNavigationBar() {
    
        self.title = self.device.deviceName
    }
    
    private func configureView() {
    
        self.configureButtons()
        self.configureLabels()
    }
    
    private func configureLabels() {
    
        self.deviceUUIDTitleLabel.text = "Device UUID"
        self.deviceUUIDValueLabel.text = "null"
        
        self.stateTitleLabel.text = "State:"
        self.stateValueLabel.text = "Disconnected"
        
        self.elapsedTimeTitleLabel.text = "Elapsed Time"
        self.elapsedTimeValueLabel.text = "00:00:00"
        
        self.outputTitleLabel.text = "Output result"
        self.outputValueLabel.text = ""
    }
    
    private func configureButtons() {
    
        self.connectButton.setTitle("Connect", forState: .Normal)
        self.connectButton.backgroundColor = secondaryColor
        self.connectButton.setTitleColor(primaryColor, forState: .Normal)
        
        self.disconnectButton.setTitle("Disconnect", forState: .Normal)
        self.disconnectButton.backgroundColor = secondaryColor
        self.disconnectButton.setTitleColor(primaryColor, forState: .Normal)
        
        self.startButton.setTitle("Start", forState: .Normal)
        self.startButton.backgroundColor = secondaryColor
        self.startButton.setTitleColor(primaryColor, forState: .Normal)
        
        self.stopButton.setTitle("Stop", forState: .Normal)
        self.stopButton.backgroundColor = secondaryColor
        self.stopButton.setTitleColor(primaryColor, forState: .Normal)
        
        self.descriptionButton.setTitle("Description", forState: .Normal)
        self.descriptionButton.backgroundColor = secondaryColor
        self.descriptionButton.setTitleColor(primaryColor, forState: .Normal)
        
        self.versionButton.setTitle("Version", forState: .Normal)
        self.versionButton.backgroundColor = secondaryColor
        self.versionButton.setTitleColor(primaryColor, forState: .Normal)
        
        self.resetButton.setTitle("Reset", forState: .Normal)
        self.resetButton.backgroundColor = secondaryColor
        self.resetButton.setTitleColor(primaryColor, forState: .Normal)
    }
    
    private func resetTimer() {
    
        self.secondsElapsed = 0
        self.timer?.invalidate()
        self.timer = nil
        
        self.elapsedTimeValueLabel.text = "00:00:00"
    }
    
    @objc private func updateElapsedTime() {

        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = 0
        
        self.secondsElapsed += 1
        
        hours = self.secondsElapsed / 3600
        minutes = (self.secondsElapsed % 3600) / 60
        seconds = (self.secondsElapsed % 3600) % 60
        
        self.elapsedTimeValueLabel.text = String(format: "%.2d:%.2d:%.2d", hours, minutes, seconds)
    }
    
    // MARK:- Actions
    
    @IBAction func actionConnectButton(sender: UIButton) {
        
        self.centralManager.connectDevice(self.device)
    }
    
    @IBAction func actionDisconnectButton(sender: UIButton) {
        
        self.centralManager.disconnectDevice(self.device)
        self.outputValueLabel.text = ""
    }
    
    @IBAction func actionStartButton(sender: UIButton) {
    
        let baseFreq: Float = 1000
        let sources: [PXSource] = [PXSource(port: 1, numberOfBits: 16, channelMask: 0x01, frequencyDivisor: 100),
                                   PXSource(port: 2, numberOfBits: 16, channelMask: 0x3F, frequencyDivisor: 100)]

//        self.device.startAcquisitionWithBaseFrequency(baseFreq, sourcesArray: sources, completionBlock: nil)
        
        self.device.startAcquisitionWithBaseFrequency(baseFreq, sourcesArray: sources) { (result, pluxFrame) in
            
            if result {
            
                if let pluxFrame = pluxFrame {
                
                    self.outputValueLabel.text = "Start: PluxFrame SEQ: \(pluxFrame.sequence) DATA: \(pluxFrame.analogData)"
                    
                    if self.timer == nil {
                    
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.updateElapsedTime), userInfo: nil, repeats: true)
                    }
                
                } else {
                
                    self.outputValueLabel.text = "Start: PluxFrame unavailable!"
                }
                
            } else {
            
                self.outputValueLabel.text = "Start: error!"
            }
        }
    }
    
    @IBAction func actionStopButton(sender: UIButton) {
        
        self.device.stopAcquisitionWithCompletionBlock { (result) in
            
            if result {
            
                self.resetTimer()
            }
            
            self.outputValueLabel.text = "Stop: \(result)"
        }
    }
    
    @IBAction func actionVersionButton(sender: UIButton) {
        
        self.device.getVersionOfDeviceWithCompletionBlock { (result, pluxDevice) in
            
            if result {
                
                if let pluxDevice = pluxDevice {
                    
                    self.outputValueLabel.text = "Version: \(pluxDevice)"
                    
                } else {
                    
                    self.outputValueLabel.text = "Version: PluxDevice unavailable!"
                }
                
            } else {
                
                self.outputValueLabel.text = "Version: error!"
            }
        }
    }
    
    @IBAction func actionDescriptionButton(sender: UIButton) {
    
        self.device.getDescriptionOfDeviceWithCompletionBlock { (result, description) in
            
            if result {
                
                if let description = description {
                    
                    self.outputValueLabel.text = "Description: \(description)"
                    
                } else {
                    
                    self.outputValueLabel.text = "Description: unavailable!"
                }
                
            } else {
                
                self.outputValueLabel.text = "Description: error!"
            }
        }
    }
    
    @IBAction func actionResetButton(sender: UIButton) {
        
        self.device.resetDevice()
        self.resetTimer()
        self.stateValueLabel.text = "Disconnected"
        self.outputValueLabel.text = "Reset pressed"
    }
    
    // MARK:- PXBiopluxDelegate
    
    func didConnectDevice() {
        
        self.stateValueLabel.text = "Connected"
        self.outputValueLabel.text = ""
        self.deviceUUIDValueLabel.text = self.device.deviceUUID
    }
    
    func didFailToConnectDevice() {
        
        self.stateValueLabel.text = "Failed to Connect"
        self.outputValueLabel.text = ""
        self.deviceUUIDValueLabel.text = self.device.deviceUUID
    }
    
    func didDisconnectDevice() {
        
        self.stateValueLabel.text = "Disconnected"
        self.outputValueLabel.text = ""
        self.deviceUUIDValueLabel.text = self.device.deviceUUID
        self.resetTimer()
    }
}
