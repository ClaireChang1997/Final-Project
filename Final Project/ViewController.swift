//
//  ViewController.swift
//  Final Project
//
//  Created by claire chang on 2024/4/16.
//

import UIKit
import CoreLocation
import CoreGraphics

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var monitorResultTextView: UITextView!
    @IBOutlet weak var rangingResultTextView: UITextView!
    @IBOutlet weak var location: UITextField!
    
    @IBAction func loaddata(_ sender: UIButton) {
        loadDataArray()
    }
    
    var dataArray = [[String:Any]]() //空的 [String:Any] dictionary array 來儲存
    var locationManager: CLLocationManager = CLLocationManager()
    
    let uuid = "A3E1C063-9235-4B25-AA84-D249950AADC4"
    let identfier = "esd region"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //要求使用者授權 location service
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways{
                locationManager.requestAlwaysAuthorization()
            }
        }
        
        let region = CLBeaconRegion(uuid: UUID.init(uuidString: uuid)!, identifier: identfier) //創造包含同樣 uuid 的 beacon 的 region
        
        locationManager.delegate = self //設定 locaiton manager 的 delegate
        
        //設定region monitoring 要被通知的時機
        region.notifyEntryStateOnDisplay = true
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)  //開始 monitoring
        
    }
            
//        func calculateTriangle() -> (CGPoint, CGPoint, CGPoint, CGPoint) {
//            // 計算三角形
//            let pointA = sidePointCalculation(x1: x1, y1: y1, r1: r1, x2: x2, y2: y2, r2: r2, x3: x3, y3: y3)
//            let pointB = sidePointCalculation(x2: x2, y2: y2, r2: r2, x3: x3, y3: y3, r3: r3, x1: x1, y1: y1)
//            let pointC = sidePointCalculation(x1: x1, y1: y1, r1: r1, x3: x3, y3: y3, r3: r3, x2: x2, y2: y2)
//            
//            // 計算三角形的重心
//            let Mx = (pointA.x + pointB.x + pointC.x) / 3
//            let My = (pointA.y + pointB.y + pointC.y) / 3
//            let centroid = CGPoint(x: Mx, y: My)
//
//            return (pointA, pointB, pointC, centroid)
//            }
//        
//        // 邊計算
//        func sidePointCalculation(x1: Double, y1: Double, r1: Double,
//                                  x2: Double, y2: Double, r2: Double,
//                                  x3: Double, y3: Double) -> CGPoint {
//            // 在這裡實現您的邏輯，可能類似於 midpointCalculation
//            // 佔位實現
//            return midpointCalculation(x1: x1, y1: y1, r1: r1, x2: x2, y2: y2, r2: r2)
//            }
//
//        // 中點計算
//        func midpointCalculation(x1: Double, y1: Double, r1: Double,
//                                 x2: Double, y2: Double, r2: Double) -> CGPoint {
//            let a = y1 - y2 // 竖邊
//            let b = x1 - x2 // 橫邊
//            let rr = r1 + r2
//            let s = r1 / rr
//
//            let x = abs(x1 - (b * s))
//            let y = abs(y1 - (a * s))
//
//            return CGPoint(x: x, y: y)
//            }
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region:CLRegion) {
        monitorResultTextView.text = "did start monitoring \(region.identifier)\n" + monitorResultTextView.text
    }        //將成功開始 monitor 的 region 的 identifier 加入到 monitor textview 最上方
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        monitorResultTextView.text = "did enter\n" + monitorResultTextView.text
    }        //將偵測到進入 region 的狀態加入到 monitor textview 最上方
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        monitorResultTextView.text = "did exit\n" + monitorResultTextView.text
    }        //將偵測到離開 region 的狀態加入到 monitor textview 最上方
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state:CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            monitorResultTextView.text = "state inside\n" + monitorResultTextView.text  //將偵測到在 region 內的狀態加入到 monitor textview 最上方
            manager.startRangingBeacons(satisfying:CLBeaconIdentityConstraint(uuid: UUID.init(uuidString: uuid)!))   //如果 device 支援 ranging iBeacon，開始 ranging 這個 region
            
        case .outside:
            monitorResultTextView.text = "state outside\n" + monitorResultTextView.text //將偵測到在 region 外的狀態加入到 monitor textview 最上方
            manager.stopMonitoring(for: region) //停止 ranging region
            
        default:
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons:[CLBeacon], in region: CLBeaconRegion) {
        rangingResultTextView.text = ""        //清空原本的ranging textview
        
        //根據rssi大小排序，rssi大的排在前面
        let orderedBeaconArray = beacons.sorted(by: { (b1, b2) -> Bool in return b1.rssi > b2.rssi})
        
        //iterate 每個收到的 beacon
        for beacon in beacons {
            //根據不同 proximity 常數設定 proximityString
            var proximityString = ""
            switch beacon.proximity {
            case .far:
                proximityString = "far"
            case .near:
                proximityString = "near"
            case .immediate:
                proximityString = "immediate"
            default :
                proximityString = "unknow"
            }
            rangingResultTextView.text = rangingResultTextView.text + "Major: \(beacon.major)" + " Minor: \(beacon.minor)" + " RSSI: \(beacon.rssi)" + " Proximity: \(proximityString)" + " Accuracy: \(beacon.accuracy)" + "\n\n";        //把這個beacon的數值放到ranging textview上
        }
    }
    
    //beacon 資料載入 Dictionary
    func loadDataArray() {
        var beaconArray = [[String:Any]]()  //宣告儲存Array最後的結果的變數
        
        guard let newRangingString = rangingResultTextView.text  else { return }
        let oneBeaconString = newRangingString.components(separatedBy: "\n\n")
        let a = oneBeaconString.count-1
        print("beacon count=",a)
        
        //iterate 每⼀筆資料的string
        if a > 1 {
            for count in 0...a-1 {
                let pendingArray = oneBeaconString[count].components(separatedBy: " ")
                
                let oldMajor = Int(pendingArray[1])
                let oldMinor = Int(pendingArray[3])
                let oldRSSI = Double(pendingArray[5])
                let oldProximity = String(pendingArray[7])
                let oldAccuracy = Double(pendingArray[9])
                print("pendingArray[",count,"]=",pendingArray)
                
                dataArray.append(["Major": oldMajor,"Minor":oldMinor, "RSSI":oldRSSI, "Proximity":oldProximity, "Accuracy":oldAccuracy])
                print("dataArray=",dataArray)
            }
        }
        
    }
    func Calculatetriangle() {
    
//    let (pointA, pointB, pointC, centroid) = calculateTriangle()
//    
//    print("點A: \(pointA)")
//    print("點B: \(pointB)")
//    print("點C: \(pointC)")
//    print("重心: \(centroid)")
    
    }

}

