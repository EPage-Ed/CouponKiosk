//
//  ViewController.swift
//  CouponKiosk
//
//  Created by Edward Arenberg on 5/8/20.
//  Copyright © 2020 Edward Arenberg. All rights reserved.
//

import UIKit
import AVFoundation

struct Coupon {
    let who : String
    let what : String
    let amount : Double
    var amountStr : String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        return nf.string(for: amount)!
    }
    var code : String
    let imageName : String
    var image : UIImage {
        return UIImage(named: imageName)!
    }
    var selected = false
    mutating func select(selected : Bool) {
        self.selected = selected
    }
    var printed = false
    mutating func print(printed : Bool) {
        self.printed = printed
    }

}

class CouponCell : UITableViewCell {
    var coupon : Coupon? {
        didSet {
            couponIV.image = coupon?.image
            whoLabel.text = coupon?.who
            whatLabel.text = coupon?.what
            amountLabel.text = "Save \(coupon?.amountStr ?? "???")"
            checkIV.isHidden = !(coupon?.selected ?? false)
        }
    }

    @IBOutlet weak var couponIV: UIImageView!
    @IBOutlet weak var whoLabel: UILabel!
    @IBOutlet weak var whatLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var checkIV: UIImageView!
    
}

extension ViewController : UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupons[section].count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return coupons.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let t = section == 0 ? "STORE" : section == 1 ? "MANUFACTURER" : "FOR YOU"
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 28)
        l.textAlignment = .center
        l.alpha = 0.5
        l.text = t
        
        return l
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CouponCell", for: indexPath) as! CouponCell
        
        let c = coupons[indexPath.section][indexPath.row]
        cell.coupon = c
//        cell.textLabel?.text = "\(c.who) : \(c.what)"
//        cell.detailTextLabel?.text = c.amountStr
//        cell.imageView?.image = c.image
        
//        cell.contentView.backgroundColor = c.printed ? .systemGray2 : .clear
        let alpha : CGFloat = c.printed ? 0.25 : 1.0
        cell.couponIV.alpha = alpha
        cell.whoLabel.alpha = alpha
        cell.whatLabel.alpha = alpha
        cell.amountLabel.alpha = alpha
        
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if coupons[indexPath.section][indexPath.row].printed { return }
        
        coupons[indexPath.section][indexPath.row].selected = !coupons[indexPath.section][indexPath.row].selected
        tableView.reloadRows(at: [indexPath], with: .fade)
        
        updatePrintButton()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}

class ViewController: UIViewController {

    var selectedPrinter: BRPtouchDeviceInfo?

    var coupons = [[Coupon]]()
    
    fileprivate var alertSoundPlayer : AVAudioPlayer!
    fileprivate let alertSound = Bundle.main.url(forResource: "kaching", withExtension: "wav")!

    @IBOutlet weak var couponTV: UITableView! {
        didSet {

        }
    }
    @IBOutlet weak var printButton: UIButton! {
        didSet {
            printButton.layer.cornerRadius = 10
            printButton.layer.masksToBounds = true
        }
    }
    @IBAction func printHit(_ sender: UIButton) {
        printCoupons(coupons:coupons.flatMap{$0}.filter{$0.selected})
        for i in 0..<coupons.count {
            for j in 0..<coupons[i].count {
                if coupons[i][j].selected { coupons[i][j].print(printed: true) }
                coupons[i][j].select(selected: false)
            }
        }
        couponTV.reloadData()
        updatePrintButton()
        alertSoundPlayer.play()
    }
    func updatePrintButton() {
        let sel = coupons.flatMap{$0}.filter { $0.selected }
        if sel.count > 0 {
            printButton.isEnabled = true
            printButton.alpha = 1
        } else {
            printButton.isEnabled = false
            printButton.alpha = 0.25
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        coupons = genCoupons()
        updatePrintButton()
        alertSoundPlayer = try? AVAudioPlayer(contentsOf: alertSound)
        alertSoundPlayer.prepareToPlay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let f = couponTV.tableHeaderView?.frame else { return }
        couponTV.tableHeaderView?.frame = CGRect(x: f.origin.x, y: f.origin.y, width: f.size.width, height: 44)
    }

    func genCoupons() -> [[Coupon]] {
        
        let coupons = [[
            Coupon(who: "Kroger's", what: "Spend $100", amount: 5.00, code: "c3d4e5f6", imageName: "Kroger")
            ],[
            Coupon(who: "Kellog's", what: "Frosted Flakes", amount: 1.00, code: "a1b2c3d4", imageName: "FrostedFlakes"),
            Coupon(who: "Ragu", what: "Traditional Sauce", amount: 1.50, code: "b2c3d4e5", imageName: "Ragu")
            ],[
                Coupon(who: "Gatorade", what: "32oz Any Flavor", amount: 0.50, code: "d4e5f6g7", imageName: "Gatorade"),
                Coupon(who: "Clif Bar", what: "Buy Three 2.4oz", amount: 0.75, code: "e5f6g7h8", imageName: "Clifbar")
            ]]
        
        
        return coupons
    }
    
    
    func printCoupons(coupons:[Coupon]) {
        for (i,c) in coupons.enumerated() {
            print(c)
            printCoupon(coupon: c)
            let img = generateCoupon(coupon: c)?.imageRotated(on: 90)
            print(img)
            
        }
        
    }

    func printCoupon(coupon:Coupon) {
        guard let selectedPrinter = selectedPrinter else { return }
        
        let channel = BRLMChannel(wifiIPAddress: selectedPrinter.strIPAddress)
        let openChannelResult = BRLMPrinterDriverGenerator.open(channel)
        
        guard openChannelResult.error.code == BRLMOpenChannelErrorCode.noError,
            let printerDriver = openChannelResult.driver else {
                print("Channel Error: \(openChannelResult.error.code.rawValue)")
                return
        }
        
        // 216 x 144 points , 3 x 2 inches , 76.2 x 50.8 mm
        //        let pdfURL = Bundle.main.url(forResource: "PDFSample", withExtension: "pdf")
        let printerSettings = BRLMQLPrintSettings(defaultPrintSettingsWith: .QL_820NWB)
        printerSettings?.labelSize = .rollW54
        printerSettings?.autoCut = true
        
        let cgImage = generateCoupon(coupon:coupon)!.imageRotated(on: 90).cgImage!
        //        let data = try! Data(contentsOf: pdfURL!)
        //        let error = printerDriver.sendRawData(data)
        let error = printerDriver.printImage(with: cgImage, settings: printerSettings!)
        
        //        let error = printerDriver.printPDF(with: pdfURL!, settings: printerSettings!)
        print("PDFSample print - result code: \(error.code.rawValue)")
        
        printerDriver.closeChannel()
    }
    
    func generateCoupon(coupon:Coupon) -> UIImage? {
        
        let ht = 216
        let wt = 400
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: wt, height: ht))
        let img = renderer.image { ctx in
                        
            let cgx = ctx.cgContext
            cgx.setFillColor(UIColor.white.cgColor)
            cgx.fill(CGRect(x: 0, y: 0, width: wt, height: ht))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 40)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            
            let string = "\(coupon.who)\n\(coupon.what)\nSave \(coupon.amountStr)"
            string.draw(with: CGRect(x: 16, y: 10, width: wt-32, height: 140), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            
            if let barImage = generateBarcode(from: coupon.code) {
                barImage.draw(in: CGRect(x: 24, y: 160 , width: wt - 48, height: 48))
            }
            
            let df = DateFormatter()
            df.dateStyle = .medium
            let str = "Exp: \(df.string(from: Date()))"
            let attrs2 = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 24)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            str.drawWithBasePoint(basePoint: CGPoint(x: 380, y: 216 * 1.4), andAngle: -CGFloat.pi/2, andAttributes: attrs2)
            
        }
        
        //        let badge = img.imageRotated(on: 90)
        
        return img
        
    }

    func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
//        if let filter = CIFilter(name: "CIQRCodeGenerator") {
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func generateBar(w:CGFloat,h:CGFloat,val:CGFloat) -> UIImage {  // val = 0 -> 1
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: w, height: h))
        let img = renderer.image { ctx in
            
            let cgx = ctx.cgContext
            cgx.setStrokeColor(UIColor.black.cgColor)
            cgx.setLineWidth(4)
            cgx.stroke(CGRect(x: 2, y: 2, width: w-4, height: h-4))

            cgx.setFillColor(UIColor.black.cgColor)
            cgx.fill(CGRect(x: 0, y: 0, width: val * w, height: h))
            
        }
        
        return img
        
    }

}

extension UIImage {
    
    func imageRotated(on degrees: CGFloat) -> UIImage {
        // Following code can only rotate images on 90, 180, 270.. degrees.
        let degrees = round(degrees / 90) * 90
        let sameOrientationType = Int(degrees) % 180 == 0
        let radians = CGFloat.pi * degrees / CGFloat(180)
        let newSize = sameOrientationType ? size : CGSize(width: size.height, height: size.width)
        
        UIGraphicsBeginImageContext(newSize)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
            return self
        }
        
        ctx.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        ctx.rotate(by: radians)
        ctx.scaleBy(x: 1, y: -1)
        let origin = CGPoint(x: -(size.width / 2), y: -(size.height / 2))
        let rect = CGRect(origin: origin, size: size)
        ctx.draw(cgImage, in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image ?? self
    }
    
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }

}

extension String {
    func drawWithBasePoint(basePoint: CGPoint,
                           andAngle angle: CGFloat,
                           andAttributes attributes: [NSAttributedString.Key : Any]) {
        let textSize: CGSize = self.size(withAttributes: attributes)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        let t: CGAffineTransform = CGAffineTransform(translationX: basePoint.x, y: basePoint.y)
        let r: CGAffineTransform = CGAffineTransform(rotationAngle: angle)
        context.concatenate(t)
        context.concatenate(r)
        self.draw(at: CGPoint(x: textSize.width / 2, y: -textSize.height / 2), withAttributes: attributes)
        context.concatenate(r.inverted())
        context.concatenate(t.inverted())
    }
}
