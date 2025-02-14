////
////  ScanTableViewController.swift
////
////  Created by Stephen Schiffli on 8/14/15.
////  Copyright (c) 2015 MbientLab Inc. All rights reserved.
////
//
//import UIKit
//import MBProgressHUD
//
//protocol ScanTableViewControllerDelegate {
//    func scanTableViewController(_ controller: ScanTableViewController, didSelectDevice device: MBLMetaWear)
//}
//
//class ScanTableViewController: UITableViewController {
//    var delegate: ScanTableViewControllerDelegate?
//    var devices: [MBLMetaWear]?
//    var selected: MBLMetaWear?
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated);
//        
//        MBLMetaWearManager.shared().startScan(forMetaWearsAllowDuplicates: true, handler: { (array: [Any]) -> Void in
//            self.devices = array as? [MBLMetaWear]
//            self.tableView.reloadData()
//        })
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        MBLMetaWearManager.shared().stopScanForMetaWears()
//    }
//
//    // MARK: - Table view data source
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let count = devices?.count {
//            return count
//        }
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MetaWearCell", for: indexPath) 
//
//        // Configure the cell...
//        if let cur = devices?[(indexPath as NSIndexPath).row] {
//            let name = cell.viewWithTag(1) as! UILabel
//            name.text = cur.name
//            
//            let uuid = cell.viewWithTag(2) as! UILabel
//            uuid.text = cur.identifier.uuidString
//            
//            if let rssiNumber = cur.discoveryTimeRSSI {
//                let rssi = cell.viewWithTag(3) as! UILabel
//                rssi.text = rssiNumber.stringValue
//            }
//        }
//        
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        if let selected = devices?[(indexPath as NSIndexPath).row] {
//            let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
//            
//            hud.labelText = "Connecting..."
//            
//            self.selected = selected
//
//            selected.connect(withTimeout: 15, handler: { (error: Error?) -> Void in
//                if let realError = error {
//                    hud.labelText = realError.localizedDescription
//                    hud.hide(true, afterDelay: 2.0)
//                } else {
//                    hud.hide(true)
//                    selected.led?.flashColorAsync(UIColor.green, withIntensity: 1.0)
//                    
//                    let alert = UIAlertController(title: "Confirm Device", message: "Do you see a blinking green LED on the MetaWear", preferredStyle: UIAlertControllerStyle.alert)
//                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction) -> Void in
//                        selected.led?.setLEDOnAsync(false, withOptions: 1)
//                        selected.disconnect(handler: nil)
//                    }))
//                    alert.addAction(UIAlertAction(title: "Yes!", style: .default, handler: { (action: UIAlertAction) -> Void in
//                        selected.led?.setLEDOnAsync(false, withOptions: 1)
//                        selected.disconnect(handler: nil)
//                        if let delegate = self.delegate {
//                            delegate.scanTableViewController(self, didSelectDevice: selected)
//                        }
//                    }))
//                    self.present(alert, animated: true, completion: nil)
//                }
//            })
//        }
//    }
//}
