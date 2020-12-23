//
//  ModbusSimulator.swift
//
//
//  Created by Jan Verrept on 28/11/2019.
//

import ClibModbus
import Foundation

open class ModbusSimulator: ModbusDriver{
    
    private var addressPageSimulatorInputs = 0
    private var addressPageSimulatorOutputs = 0
    private let addressPageLengthPerModule = 100
    
    public override init(ipAddress:String = "127.0.0.1", port:Int = 1502){
        super.init(ipAddress:ipAddress, port:port)
    }
    
    deinit {
        disConnect()
    }
    
    public override func readAllInputs(){
        
        switch connectionState{
        case .disconnected:
            print("⛓ connecting @\(ipAddress)")
            connect()
        case .connected:
            print("✅ reading simulated inputs @\(ipAddress)")
            addressPageSimulatorInputs = 0
            modbusModules.forEach{
                let pageStart = addressPageSimulatorInputs*addressPageLengthPerModule
                $0.readAllInputs(connection: modbusConnection, pageStart:pageStart)
                addressPageSimulatorInputs += 1
            }
        case .error:
            break // Just wait for automatic retry
        }
    }
    
    public override func writeAllOutputs(){
        
        switch connectionState{
        case .disconnected:
            print("⛓ connecting @\(ipAddress)")
            connect()
        case .connected:
            print("✅ writing simulated outputs @\(ipAddress)")
            addressPageSimulatorOutputs = 0
            modbusModules.forEach{
                let pageStart = addressPageSimulatorOutputs*addressPageLengthPerModule
                $0.writeAllOutputs(connection: modbusConnection,addressPage:pageStart)
                addressPageSimulatorOutputs += 1
            }
        case .error:
            break // Just wait for automatic retry
        }
    }
    
}


