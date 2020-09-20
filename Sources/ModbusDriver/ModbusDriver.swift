import ClibModbus
import Foundation

@available(OSX 10.12, *)
open class ModbusDriver{
    
    enum ConnectionState{
        case disconnected
        case connected
        case error
    }
    
    let ipAddress:String
    let portNumber:Int
    var modbusConnection:OpaquePointer! = nil
    var connectionState:ConnectionState = .disconnected
    
    let connectionTTL:TimeInterval = 15.0
    let retryInterval:TimeInterval = 60.0
    
    public var ioModules:[IOmodule] = []
    
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
            DispatchQueue.main.asyncAfter(deadline: .now() + connectionTTL) {self.disConnect()}
        }else{
            connectionState = .error
            modbus_free(modbusConnection)
            DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {self.connect()}
        }
    }
    
    func disConnect(){
        if connectionState == .connected{
            modbus_close(modbusConnection)
            connectionState = .disconnected
            modbus_free(modbusConnection)
        }
    }
    
    
    public func readAllInputs(){
        //        if !isConnected{
        //        //            connect()
        //        //        }
        //        if connectionState == .connected{
        //            ioModules.forEach{$0.readAllInputs(connection: modbusConnection)}
        //        }
    }
    
    public func writeAllOutputs(){
        
        switch connectionState{
        case .disconnected:
            print("⛓ connecting")
            connect()
        case .connected:
            print("✅ connection on write")
            ioModules.forEach{$0.writeAllOutputs(connection: modbusConnection)}
        case .error:
            break // Just wait foor automatic retry
        }
    }
    
}


