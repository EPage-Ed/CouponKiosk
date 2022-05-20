//
//  SplashVC.swift
//  CouponKiosk
//
//  Created by Edward Arenberg on 5/8/20.
//  Copyright © 2020 Edward Arenberg. All rights reserved.
//

import UIKit

extension SplashVC: BRPtouchNetworkDelegate {
    
    // You must implement this delegated method to receive an array
    // of found devices. Note that getPrinterNetInfo() returns an
    // array of type Any; cast devices to BRPtouchDeviceInfo elements
    // to expose all of the handy properties you will need later.
    
    /*
     IPAddress: 10.0.0.33,   Location: ,   ModelName: Brother QL-820NWB,   SerialNumber: M9Z611497,   NodeName: BRW4023439C3178,   PrinterName: Brother QL-820NWB,   MACAddress: 40:23:43:9c:31:78LocalIdentifier: (null)
     */
    func didFinishSearch(_ sender: Any!) {
        guard
            let manager = sender as? BRPtouchNetworkManager,
            let devices = manager.getPrinterNetInfo()
        else { return }
        
        for deviceInfo in devices {
            guard let deviceInfo = deviceInfo as? BRPtouchDeviceInfo else { continue }
            
            if deviceInfo.strModelName == "Brother QL-820NWB" {
//            if deviceInfo.strIPAddress == "10.0.0.33" {
                myPrinter = deviceInfo
            }
            
//            printers.append(deviceInfo)
        }
        
        spinner.stopAnimating()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SignInVC") as? SignInVC {
            vc.selectedPrinter = myPrinter
            view.window?.rootViewController = vc
        }
                
    }
}

class SplashVC: UIViewController {

    private var networkManager: BRPtouchNetworkManager?
    private var myPrinter: BRPtouchDeviceInfo?

    @IBOutlet weak var spinner: UIActivityIndicatorView!

    func connectPrinter() {
        spinner.startAnimating()
        
        let manager = BRPtouchNetworkManager()
        manager.delegate = self
        manager.isEnableIPv6Search = false
        manager.setPrinterNames(allBrotherPrinters())

        manager.startSearch(5)
        self.networkManager = manager

    }

    fileprivate func allBrotherPrinters() -> [String] {
        guard let printNamesURL = Bundle.main.url(forResource: "PrinterList", withExtension: "plist")
            else { fatalError("PrinterList.plist missing in bundle") }
        
        let printersDict = NSDictionary.init(contentsOf: printNamesURL)!
        let printersArray = printersDict.allKeys as! [String]
        
        return printersArray
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectPrinter()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
