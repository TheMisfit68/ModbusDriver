//
//  ModbusDriver.swift
//
//
//  Created by Jan Verrept on 28/11/2019.
//

import ClibModbus
import Foundation

open class ModbusDriver{
    
    enum ConnectionState{
        case disconnecting
        case disconnected
        case connecting
        case connected
        case error
    }
    
    let ipAddress:String
    let portNumber:Int
    var modbusConnection:OpaquePointer! = nil
    var connectionState:ConnectionState = .disconnected
    
    let connectionTTL:TimeInterval = 15.0
    let retryInterval:TimeInterval = 60.0
    
    public var modbusModules:[ModBusModule] = []
    
    public init(ipAddress:String, port:Int = 502){
        self.ipAddress = ipAddress
        self.portNumber = port
    }
    
    deinit {
        disConnect()
    }
    
    func connect(){
        modbusConnection = modbus_new_tcp(self.ipAddress, Int32(self.portNumber))
        if modbus_connect(modbusConnection) != -1 {
            connectionState = .connected
            DispatchQueue.main.asyncAfter(deadline: .now() + connectionTTL) {self.connectionState = .disconnecting}
        }else{
            connectionState = .error
            modbus_free(modbusConnection)
            DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {self.connectionState = .connecting}
        }
    }
    
    func disConnect(){
        modbus_close(modbusConnection)
        modbus_free(modbusConnection)
        connectionState = .disconnected
    }
    
    
    public func readAllInputs(){
        
        switch connectionState{
        case .disconnecting:
            print("❌ disconnecting @\(ipAddress)")
            disConnect()
        case .disconnected:
            connectionState = .connecting
        case .connecting:
            print("⛓ connecting @\(ipAddress)")
            connect()
        case .connected:
            print("✅ reading inputs @\(ipAddress)")
            for modbusModule in modbusModules{
                let readResult = modbusModule.readAllInputs(connection: modbusConnection)
                if readResult != .noError{
                    connectionState = .error
                    print("❌ error reading inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
                    break
                }
            }
        case .error:
            break // Just wait for automatic retry
        }
        
    }
    
    public func writeAllOutputs(){
        
        switch connectionState{
        case .disconnecting:
            print("❌ disconnecting @\(ipAddress)")
            disConnect()
        case .disconnected:
            connectionState = .connecting
        case .connecting:
            print("⛓ connecting @\(ipAddress)")
            connect()
        case .connected:
            print("✅ writing outputs @\(ipAddress)")
            for modbusModule in modbusModules{
                let writeResult = modbusModule.writeAllOutputs(connection: modbusConnection)
                if writeResult != .noError{
                    connectionState = .error
                    print("❌ error writing inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
                    break
                }
            }
        case .error:
            break // Just wait for automatic retry
        }
    }
    
}


