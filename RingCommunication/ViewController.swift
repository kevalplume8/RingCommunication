//
//  ViewController.swift
//  RingCommunication
//
//  Created by Keval Patel on 6/17/22.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var tblOfList: UITableView!
    @IBOutlet weak var btnOfScan: UIBarButtonItem!
    
    var peripherals:[CBPeripheral] = []
    var centralManager: CBCentralManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblOfList.delegate = self
        tblOfList.dataSource = self
        self.tblOfList.tableFooterView = UIView()
        centralManager = CBCentralManager(delegate: self, queue: .main)
        
    }
    
    @IBAction func btnScanClick( sender: Any) {
        print("scan Start")
        centralManager?.scanForPeripherals(withServices: nil, options:  [CBCentralManagerScanOptionAllowDuplicatesKey: true as AnyObject])
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.centralManager.stopScan()
            print("Scanning stop")
        }
    }
}


extension ViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblOfList.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = peripherals[indexPath.row].name ?? "Unknown"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        centralManager.connect(peripherals[indexPath.row])
    }
}


extension ViewController : CBPeripheralDelegate, CBCentralManagerDelegate{
    internal func centralManager( _ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard !peripherals.contains(peripheral) else { return }
        self.peripherals.append(peripheral)
        self.tblOfList.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let deviceDetailViewController = storyBoard.instantiateViewController(withIdentifier: "DeviceDetailViewController") as! DeviceDetailViewController
        deviceDetailViewController.peripheral = peripheral
        self.navigationController?.pushViewController(deviceDetailViewController, animated: true)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error)
    }
    
    func centralManagerDidUpdateState( _ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
        @unknown default:
            fatalError()
        }
    }
}
