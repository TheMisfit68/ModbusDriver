//
//  IOSignal.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus

enum ModbusIOtype{
    case analogIn
    case analogOut
    case digitalIn
    case digitalOut
}

class IOsignal{
    
    var ioType:ModbusIOtype
    var number:Int
    
    init(channelType:ModbusIOtype, channelNumber:Int){
        self.ioType = channelType
        self.number = channelNumber
    }
    
}

class AnalogInputsignal:IOsignal{
    
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
    var value:Float = 0.0
    
    func setScale(_ scale:ClosedRange<Float>, unit:String){
        self.scale = scale
        self.unit = unit
    }
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.analogIn, channelNumber: channelNumber)
    }
}

class AnalogOutputsignal:IOsignal{
    
    
    let scale:ClosedRange<Float> = 0.0...100.0
    let unit:String = "%"
    var value:Float = 0.0{
        didSet{
            ioValue = UInt16(value/100.0*Float(UInt16.max))
        }
    }
    var ioValue:UInt16 = 0
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.analogOut, channelNumber: channelNumber)
    }
}

class DigitalInputsignal:IOsignal{
    
    var ioValue:Bool = false{
        didSet{
            value = ioValue
        }
    }
    var value:Bool =  false
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.digitalIn, channelNumber: channelNumber)
    }
}

class DigitalOutputsignal:IOsignal{
    
    var value:Bool = false{
        didSet{
            ioValue = value
        }
    }
    var ioValue:Bool = false
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.digitalOut, channelNumber: channelNumber)
    }
}
