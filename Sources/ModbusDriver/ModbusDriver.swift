import ClibModbus

public class ModbusDriver{
    
    public func test()->[UInt8]{
        
        let mb = modbus_new_tcp("127.0.0.1", 1502)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 2)
        modbus_connect(mb)
        
        /* Read 5 registers from the address 0 */
        modbus_read_input_bits(mb, 0, 16, result)
        
        print(result.pointee)
        
        var resultArr:[UInt8] = []
        
        for n in 0...1 {
            resultArr[n] = result[n]
        }
        
        modbus_close(mb)
        
        return resultArr
        
    }
    
    public init(){
        
    }
    
}


