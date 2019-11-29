import ClibModbus

public class ModbusDriver{
    
    let ipAddress:String
    let portNumber:Int
    let modbusConnection:OpaquePointer
    var modules:[IOmodule] = []
    
    init(ipAddress:String, port:Int){
        
        self.ipAddress = ipAddress
        self.portNumber = port
        
        modbusConnection = modbus_new_tcp(ipAddress, Int32(port));
        modbus_connect(modbusConnection)
    }
    
    deinit {
        modbus_close(modbusConnection)
        modbus_free(modbusConnection)
    }
    
    func readAllInputs(){
        modules.forEach{$0.readAllInputs()}
    }
    
    func writeAllOutputs(){
        modules.forEach{$0.writeAllOutputs()}
    }
}


