import ClibModbus

class ModbusDriver{
    
    func test(){
        
        let mb = modbus_new_tcp("127.0.0.1", 1502);
        let result = UnsafeMutablePointer<UInt16>.allocate(capacity: 32)
        modbus_connect(mb);
        
        /* Read 5 registers from the address 0 */
        modbus_read_registers(mb, 0, 5, result);
        
        modbus_close(mb);
        
    }
    
}

