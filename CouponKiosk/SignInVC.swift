//
//  SignInVC.swift
//  CouponKiosk
//
//  Created by Edward Arenberg on 5/9/20.
//  Copyright © 2020 Edward Arenberg. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {

    var selectedPrinter: BRPtouchDeviceInfo?

    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            continueButton.layer.cornerRadius = 10
            continueButton.layer.masksToBounds = true
        }
    }
    @IBAction func continueHit(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "FetchVC") as? FetchVC {
            vc.selectedPrinter = selectedPrinter
            view.window?.rootViewController = vc
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
