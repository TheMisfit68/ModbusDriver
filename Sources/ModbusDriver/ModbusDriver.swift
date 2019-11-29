import ClibModbus

public class ModbusDriver{
    
    let ipAddress:String
    let portNumber:Int
    let modbusConnection:OpaquePointer
    var modules:[IOmodule] = []
    
    public init(ipAddress:String, port:Int){
        
        self.ipAddress = ipAddress
        self.portNumber = port
        
        modbusConnection = modbus_new_tcp(ipAddress, Int32(port));
        modbus_connect(modbusConnection)
    }
    
    public deinit {
        modbus_close(modbusConnection)
        modbus_free(modbusConnection)
    }
    
    public func readAllInputs(){
        modules.forEach{$0.readAllInputs()}
    }
    
    public func writeAllOutputs(){
        modules.forEach{$0.writeAllOutputs()}
    }
}


