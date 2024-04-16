//
//  ViewController.swift
//  Final Project
//
//  Created by claire chang on 2024/4/16.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
   
    @IBOutlet weak var monitorResultTextView: UITextView!
    @IBOutlet weak var rangingResultTextView: UITextView!
    
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
}

