//
//  BackfireBLEManager.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-05.
//

import Foundation
import CoreBluetooth

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
}

class BackfireBoard: NSObject {
    public static let UUIDread     = CBUUID.init(string: "0000f1f2-0000-1000-8000-00805f9b34fb")
    public static let UUIDwrite   = CBUUID.init(string: "0000f1f1-0000-1000-8000-00805f9b34fb")
    public static let UUIDservice = CBUUID.init(string: "0000f1f0-0000-1000-8000-00805f9b34fb")
    public static let UUIDreadShort = CBUUID.init(string: "F1F2")
    public static let UUIDserviceShort = CBUUID.init(string: "F1F0")
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    var myCentral: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    @Published var peripheral: CBPeripheral?
    @Published var bytesOne: Data = Data()
    @Published var bytesTwenty: Data = Data()
    @Published var speed = 0
    @Published var battery = 0
    @Published var mode = "Off"
    @Published var modeNum = 0
    @Published var tripDistance = 0
    @Published var isConnected = false
    @Published var isSearching = false

    override init() {
        super.init()

        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }


    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        } else {
            isSwitchedOn = false
        }
        var consoleLog = ""
        switch central.state {
        case .poweredOff:
          consoleLog = "BLE is powered off"
        case .poweredOn:
          consoleLog = "BLE is powered on"
        case .resetting:
          consoleLog = "BLE is resetting"
        case .unauthorized:
          consoleLog = "BLE is unauthorized"
        case .unknown:
          consoleLog = "BLE is unknown"
        case .unsupported:
          consoleLog = "BLE is unsupported"
        default:
          consoleLog = "default"
        }
        print(consoleLog)
    }


    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!

        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }

        if peripheralName.count > 3 {
            let index = peripheralName.index(peripheralName.startIndex, offsetBy: 3)
            if peripheralName[..<index] == "BF_" {
                let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)
                print(newPeripheral)
                peripherals.append(newPeripheral)
                stopScanning()
                self.peripheral = peripheral
                self.peripheral?.delegate = self
                self.myCentral.connect(self.peripheral!, options: nil)
            }
        }
    }

    func startScanning() {
         print("startScanning")
        self.isSearching = true
        myCentral.scanForPeripherals(withServices: nil, options: nil)
     }

    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
    }

    func stopScanningAndResetData() {
        myCentral.stopScan()
        self.isConnected = false
        self.isSearching = false
    }

    func disconnect() {
        self.isConnected = false
        myCentral.cancelPeripheralConnection(peripheral!)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            self.isSearching = false
            self.isConnected = true
            peripheral.discoverServices(nil)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
                return
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral {
            self.peripherals = [Peripheral]()
            self.peripheral = nil
            if (self.isConnected == true) {
                self.isConnected = false
                self.isSearching = true
                self.startScanning()
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.discoverDescriptors(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.value?.count == 20 {
            self.bytesTwenty = characteristic.value!
            if (characteristic.value?[6]) != nil {
                self.speed = Int(characteristic.value![6]) / 4
            }

            if characteristic.value?[5] != nil {
                self.battery = Int(characteristic.value![5])
            }
            var theMode = 0
            if characteristic.value?[4] != nil {
                theMode = Int(characteristic.value![4])
                self.modeNum = theMode
            }
            if theMode == 1 {
                self.mode = "Economy"
            } else if theMode == 2 {
                self.mode = "Speed"
            } else if theMode == 3 {
                self.mode = "Turbo"
            }
            if (characteristic.value?[17] != nil) {
                self.tripDistance = Int(characteristic.value![17])
            }
        } else if characteristic.value?.count == 5 {
            self.bytesOne = characteristic.value!
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
    }
}
