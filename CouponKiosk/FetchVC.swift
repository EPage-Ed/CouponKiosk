//
//  FetchVC.swift
//  CouponKiosk
//
//  Created by Edward Arenberg on 5/9/20.
//  Copyright © 2020 Edward Arenberg. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class FetchVC: UIViewController {

    var selectedPrinter: BRPtouchDeviceInfo?

    private var locationManager : CLLocationManager!
    private let defaultUUID = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0" // "B5B182C7-EAB1-4988-AA99-B5C1517008D9"  "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
    //    private var beaconConstraints = [CLBeaconIdentityConstraint: [CLBeacon]]()
    private var beacons = [CLProximity: [CLBeacon]]()
    private var locAuthorized = false

    fileprivate var alertSoundPlayer : AVAudioPlayer!
    fileprivate let alertSound = Bundle.main.url(forResource: "reveal", withExtension: "wav")!

    @IBOutlet weak var checkIV: UIImageView! {
        didSet {
            checkIV.isHidden = true
        }
    }
    @IBOutlet weak var nearPV: UIProgressView! {
        didSet {
            nearPV.layer.cornerRadius = 5
            nearPV.layer.masksToBounds = true
        }
    }
    
    private var near : Float = 0 {
        didSet {
            nearPV.progress = near
            if near >= 1 {
                alertSoundPlayer.play()
                checkIV.isHidden = false
                scanning = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                        vc.selectedPrinter = self.selectedPrinter
                        self.view.window?.rootViewController = vc
                    }
                }
            }
        }
    }

    private var scanning = false {
        didSet {
            if scanning {

            } else {
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nearPV.transform = nearPV.transform.scaledBy(x: 1, y: 10)
        
        alertSoundPlayer = try? AVAudioPlayer(contentsOf: alertSound)
        alertSoundPlayer.prepareToPlay()
        
        enableLocationServices()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    private func startBeaconMonitor() {
        guard let uuid = UUID(uuidString: defaultUUID) else { return }
        //        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        //        self.beaconConstraints[constraint] = []
        //        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: uuid.uuidString)
//        self.locationManager.startMonitoring(for: beaconRegion)
        self.locationManager.startRangingBeacons(in: beaconRegion)
        print("RANGE")
    }
    
    private func stopBeaconMonitor() {
        guard let uuid = UUID(uuidString: defaultUUID) else { return }
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: uuid.uuidString)
        self.locationManager.stopRangingBeacons(in: beaconRegion)
        self.locationManager.stopMonitoring(for: beaconRegion)
    }


}

extension FetchVC : CLLocationManagerDelegate {
    func enableLocationServices() {
        if locationManager == nil { locationManager = CLLocationManager() }
        locationManager.delegate = self
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.activityType = .fitness
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //        locationManager.distanceFilter = 5
        //        locationManager.pausesLocationUpdatesAutomatically = false
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedAlways, .authorizedWhenInUse:
//            locationManager.startUpdatingLocation()
//            startBeaconMonitor()
            
            break
            
        case .restricted, .denied:
            fallthrough
            
        @unknown default:
            //            Log.location.info("Cannot enable location services")
            //            currentLocation = nil
            break
        }
    }
    
    /// Delegate method called when the authorization status changes.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locAuthorized = true
            //            Log.location.info("Location services authorized -- enabled")
//            locationManager.startUpdatingLocation()
//            //            locationManager.startMonitoringSignificantLocationChanges()
            startBeaconMonitor()
            
        case .notDetermined, .restricted, .denied:
            fallthrough
            
        @unknown default:
            //            Log.location.info("Location services not authorized -- disabled")
            //            currentLocation = nil
            break
        }
    }
    
    /// Delegate method called when the location changes.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We are only interested in the last location in the array.
        guard let location = locations.last else {
            return
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else { return }
        if state == .inside {
            // Start ranging when inside a region.
//            manager.startRangingBeacons(in: beaconRegion)
        } else {
            // Stop ranging when not inside a region.
//            manager.stopRangingBeacons(in: beaconRegion)
        }
    }
    
    /// - Tag: didRange
    
//    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if let b = beacons.first {
            
            print(b.minor,b.proximity.rawValue,b.rssi)
            
            if false && b.proximity == .immediate {
                near = 1
                stopBeaconMonitor()
            } else if b.proximity == .immediate || b.proximity == .near || b.proximity == .far {
                // rssi -40 to -70 -> 1 to 0
                let dist = Float(max(0,100 + b.rssi)) // 60+ to 30-
                let d = fmin(30,fmax(0,dist - 30))   // 30 to 0
                let n = d / 30
                near = n
            } else {
                near = 0
            }
            
            
        }
    
    }


}
