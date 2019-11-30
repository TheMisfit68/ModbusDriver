//
//  IOSignal.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus

public enum ModbusIOtype{
    case analogIn
    case analogOut
    case digitalIn
    case digitalOut
}

public class IOsignal{
    
    public var ioType:ModbusIOtype
    public var number:Int
    
    init(channelType:ModbusIOtype, channelNumber:Int){
        self.ioType = channelType
        self.number = channelNumber
    }
    
}

public class AnalogInputSignal:IOsignal{
    
    var scale:ClosedRange<Float> = 0.0...100.0
    var unit:String = ""
    var ioValue:UInt16 = 0{
        didSet{
            let minScale = scale.lowerBound
            let range = (scale.upperBound-scale.lowerBound)
            let ioPercentage = Float(ioValue)/Float(UInt16.max)
            value = minScale+(ioPercentage*range)
        }
    }
    public var value:Float = 0.0
    
    func setScale(_ scale:ClosedRange<Float>, unit:String){
        self.scale = scale
        self.unit = unit
    }
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.analogIn, channelNumber: channelNumber)
    }
}

public class AnalogOutputSignal:IOsignal{
    
    
    let scale:ClosedRange<Float> = 0.0...100.0
    let unit:String = "%"
    public var value:Float = 0.0{
        didSet{
            ioValue = UInt16(value/100.0*Float(UInt16.max))
        }
    }
    var ioValue:UInt16 = 0
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.analogOut, channelNumber: channelNumber)
    }
}

public class DigitalInputSignal:IOsignal{
    
    var ioValue:Bool = false{
        didSet{
            value = ioValue
        }
    }
    public var value:Bool =  false
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.digitalIn, channelNumber: channelNumber)
    }
}

public class DigitalOutputSignal:IOsignal{
    
    public var value:Bool = false{
        didSet{
            ioValue = value
        }
    }
    var ioValue:Bool = false
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.digitalOut, channelNumber: channelNumber)
    }
}
