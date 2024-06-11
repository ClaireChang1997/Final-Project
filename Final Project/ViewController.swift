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
    @IBOutlet weak var location: UITextView!
    
    @IBAction func loaddata1(_ sender: UIButton) {
        loadDataArray()
        calculateM1Triangle()
        ClearDataArray()
    }
    
    @IBAction func loaddata2(_ sender: UIButton) {
        loadDataArray()
        calculateM2Triangle()
        ClearDataArray()
    }
    
    var locationManager: CLLocationManager = CLLocationManager()
    var dataFrame: [DataRow] = []    // Create an array of DataRow to represent the dataframe
    var MinorArray = [Int]()
    var AccuracyArray = [Double]()

    
    // Define a struct to represent each row in the dataframe
    struct DataRow {
        var major: Int
        var minor: Int
        var rssi: Double
        var proximity: String
        var accuracy: Double
    }
    
    //Major 1 的四個 Beacon
    let M1BeaconX = [2.21, 4.3, 4.3, 2.64]
    let M1BeaconY = [0, 5.7, 7.8, 11.75]
    //Major 2 的八個 Beacon
    let M2BeaconX = [0, 2.6, 5.71, 9.7, 13.5, 15.1, 17.5, 16.9]
    let M2BeaconY = [0, 2.67, 2.67, 2.67, 2.67, 0, 0, 3.9]
    
    
    let uuid = "A3E1C063-9235-4B25-AA84-D249950AADC4"
    let identfier = "esd region"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataArray()

        
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
        //let orderedBeaconArray = beacons.sorted(by: { (b1, b2) -> Bool in return b1.rssi > b2.rssi})
        
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
        
        guard let newRangingString = rangingResultTextView.text  else { return }
        let oneBeaconString = newRangingString.components(separatedBy: "\n\n")
        let a = oneBeaconString.count-1
        print("\n","beacon count=",a)
        
        //iterate 每⼀筆資料的string
        if a > 1 {
            for count in 0...a-1 {
                let pendingArray = oneBeaconString[count].components(separatedBy: " ")
                
                let oldMajor = Int(pendingArray[1])!
                let oldMinor = Int(pendingArray[3])!
                let oldRSSI =  Double(pendingArray[5])!
                let oldProximity = String(pendingArray[7])
                let oldAccuracy = Double(pendingArray[9])!
                print("pendingArray[",count,"]=",pendingArray)
                
                let newRow = DataRow(major: oldMajor, minor: oldMinor, rssi: oldRSSI, proximity: oldProximity, accuracy: oldAccuracy)
                dataFrame.append(newRow)

            }

            // Sort the dataframe by RSSI in ascending order
            dataFrame.sort { $0.rssi > $1.rssi }
            
            // Print the sorted dataframe
            for row in dataFrame {
                print("Major: \(row.major), Minor: \(row.minor), RSSI: \(row.rssi), Proximity: \(row.proximity), Accuracy: \(row.accuracy)")
                MinorArray.append(row.minor)
                AccuracyArray.append(row.accuracy)
            }
            print("minor=",MinorArray[0],", ",MinorArray[1],", ",MinorArray[2])
            print("minorArray=",MinorArray)
        }
        
    }
    
    func ClearDataArray() {
        dataFrame = []
        MinorArray = []
        AccuracyArray = []
    }
    
    func calculateM1Triangle() -> (CGPoint, CGPoint, CGPoint, CGPoint) {
        
        let x1 = M1BeaconX[MinorArray[0]-1]
        let x2 = M1BeaconX[MinorArray[1]-1]
        let x3 = M1BeaconX[MinorArray[2]-1]
        let y1 = M1BeaconY[MinorArray[0]-1]
        let y2 = M1BeaconY[MinorArray[1]-1]
        let y3 = M1BeaconY[MinorArray[2]-1]
        let r1 = AccuracyArray[0]
        let r2 = AccuracyArray[1]
        let r3 = AccuracyArray[2]

        // 計算三角形
        let pointA = sidePointCalculation(x1: x1, y1: y1, r1: r1, x2: x2, y2: y2, r2: r2, x3: x3, y3: y3)
        let pointB = sidePointCalculation(x1: x2, y1: y2, r1: r2, x2: x3, y2: y3, r2: r3, x3: x1, y3: y1)
        let pointC = sidePointCalculation(x1: x1, y1: y1, r1: r1, x2: x3, y2: y3, r2: r3, x3: x2, y3: y2)

        // 計算三角形的重心
        let Mx = (pointA.x + pointB.x + pointC.x) / 3
        let My = (pointA.y + pointB.y + pointC.y) / 3
        let centroid = CGPoint(x: Mx, y: My)
        
        let dist = ["A","B","C","C (強制)"]
        var dd = 5
        
        if MinorArray[0] == 1 && AccuracyArray[0] < 2 {dd = 3}
        else if My > 7.21 {dd = 0}
        else if My < 2.67 {dd = 2}
        else {dd = 1}

        location.text = "在第1關，平板的位置是:\n \(centroid)\n"+"屬於"+"\(dist[dd])區\n\n" + "點A: \(pointA)\n" + "點B: \(pointB)\n" + "點C: \(pointC)\n"
        
        return (pointA, pointB, pointC, centroid)
        }
    func calculateM2Triangle() -> (CGPoint, CGPoint, CGPoint, CGPoint) {
        
        let x1 = M2BeaconX[MinorArray[0]-1]
        let x2 = M2BeaconX[MinorArray[1]-1]
        let x3 = M2BeaconX[MinorArray[2]-1]
        let y1 = M2BeaconY[MinorArray[0]-1]
        let y2 = M2BeaconY[MinorArray[1]-1]
        let y3 = M2BeaconY[MinorArray[2]-1]
        let r1 = AccuracyArray[0]
        let r2 = AccuracyArray[1]
        let r3 = AccuracyArray[2]

        // 計算三角形
        let pointA = sidePointCalculation(x1: x1, y1: y1, r1: r1, x2: x2, y2: y2, r2: r2, x3: x3, y3: y3)
        let pointB = sidePointCalculation(x1: x2, y1: y2, r1: r2, x2: x3, y2: y3, r2: r3, x3: x1, y3: y1)
        let pointC = sidePointCalculation(x1: x1, y1: y1, r1: r1, x2: x3, y2: y3, r2: r3, x3: x2, y3: y2)

        // 計算三角形的重心
        let Mx = (pointA.x + pointB.x + pointC.x) / 3
        let My = (pointA.y + pointB.y + pointC.y) / 3
        let centroid = CGPoint(x: Mx, y: My)
        
        location.text = "在第2關，平板的位置是:\n \(centroid)\n\n" + "點A: \(pointA)\n" + "點B: \(pointB)\n" + "點C: \(pointC)\n"

        return (pointA, pointB, pointC, centroid)
        }
    

    // 邊計算
    func sidePointCalculation(x1: Double, y1: Double, r1: Double,
                              x2: Double, y2: Double, r2: Double,
                              x3: Double, y3: Double) -> CGPoint {
        // 在這裡實現您的邏輯，可能類似於 midpointCalculation
        // 佔位實現
        return midpointCalculation(x1: x1, y1: y1, r1: r1, x2: x2, y2: y2, r2: r2)
        }

    // 中點計算
    func midpointCalculation(x1: Double, y1: Double, r1: Double,
                             x2: Double, y2: Double, r2: Double) -> CGPoint {
        let a = y1 - y2 // 竖邊
        let b = x1 - x2 // 橫邊
        let rr = r1 + r2
        let s = r1 / rr

        let x = abs(x1 - (b * s))
        let y = abs(y1 - (a * s))

        return CGPoint(x: x, y: y)
        }
}

