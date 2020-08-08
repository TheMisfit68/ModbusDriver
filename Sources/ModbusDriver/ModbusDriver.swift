import ClibModbus
import Foundation

@available(OSX 10.12, *)
public class ModbusDriver{
    
    let ipAddress:String
    let portNumber:Int
    var modbusConnection:OpaquePointer! = nil
    public var ioModules:[IOmodule] = []
    private var cyclicPollingTimer:Timer!
    
    public init(ipAddress:String, port:Int = 502){
        
        self.ipAddress = ipAddress
        self.portNumber = port
        self.cyclicPollingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.readAllInputs()
            self.writeAllOutputs()
        }
        cyclicPollingTimer.tolerance = 0.5 // Give the processor some slack
    }
    
    deinit {
        closeConnection()
    }
    
    func connect(){
        modbusConnection = modbus_new_tcp(self.ipAddress, Int32(self.portNumber))
        modbus_connect(modbusConnection)
    }
    
    func closeConnection(){
        modbus_close(modbusConnection)
        modbus_free(modbusConnection)
    }
    
    
    
    public func readAllInputs(){
        connect()
        ioModules.forEach{$0.readAllInputs(connection: modbusConnection)}
        closeConnection()
    }
    
    public func writeAllOutputs(){
        connect()
        ioModules.forEach{$0.writeAllOutputs(connection: modbusConnection)}
        closeConnection()
    }
    
    
    
}


