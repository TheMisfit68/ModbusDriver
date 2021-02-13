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
    
    public override init(ipAddress:String = "127.0.0.1", port:Int = 502){
        super.init(ipAddress:ipAddress, port:port)
    }
    
    deinit {
        disConnect()
    }
    
    public override func readAllInputs(){
        
        switch connectionState{
        case .disconnecting:
            disConnect()
        case .disconnected:
            connectionState = .connecting
        case .connecting:
            print("⛓ connecting @\(ipAddress)")
            connect()
        case .connected:
            print("✅ reading simulated inputs @\(ipAddress)")
            addressPageSimulatorInputs = 0
            for modbusModule in modbusModules{
                let pageStart = addressPageSimulatorInputs*addressPageLengthPerModule
                
                let readResult = modbusModule.readAllInputs(connection: modbusConnection, pageStart:pageStart)
				guard readResult == .noError else{
                    connectionState = .error
                    print("❌ error reading simulated inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
                    break
                }
                addressPageSimulatorInputs += 1
            }
        case .error:
            break // Just wait for automatic retry
        }
    }
    
    public override func writeAllOutputs(){
        
        switch connectionState{
        case .disconnecting:
            disConnect()
        case .disconnected:
            connectionState = .connecting
        case .connecting:
            print("⛓ connecting @\(ipAddress)")
            connect()
        case .connected:
            print("✅ writing simulated outputs @\(ipAddress)")
            addressPageSimulatorOutputs = 0            
            for modbusModule in modbusModules{
                let pageStart = addressPageSimulatorOutputs*addressPageLengthPerModule

                let writeResult = modbusModule.writeAllOutputs(connection: modbusConnection, addressPage:pageStart)
				guard writeResult == .noError else{
                    connectionState = .error
                    print("❌ error writing simulated inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
                    break
                }
                addressPageSimulatorOutputs += 1
            }
            
        case .error:
            break // Just wait for automatic retry
        }
    }
    
}


