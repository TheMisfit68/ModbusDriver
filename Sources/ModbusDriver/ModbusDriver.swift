import ClibModbus

public class ModbusDriver{
    
    let ipAddress:String
    let portNumber:Int
    var modbusConnection:OpaquePointer! = nil
    var modules:[IOmodule] = []
    
    public init(ipAddress:String, port:Int){
        
        self.ipAddress = ipAddress
        self.portNumber = port
            
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
        modules.forEach{$0.readAllInputs(connection: modbusConnection)}
        closeConnection()
    }
    
    public func writeAllOutputs(){
        connect()
        modules.forEach{$0.writeAllOutputs(connection: modbusConnection)}
        closeConnection()
    }
}


