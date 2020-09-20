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

@available(OSX 10.12, *)
public class IOsignal{
    
    public var ioType:ModbusIOtype
    public var number:Int
    
    init(channelType:ModbusIOtype, channelNumber:Int){
        self.ioType = channelType
        self.number = channelNumber
    }
    
}

@available(OSX 10.12, *)
public class AnalogInputSignal:IOsignal{
    
    var scale:ClosedRange<Float> = 0.0...100.0
    var unit:String = ""
    var ioValue:UInt16 = 0{
        didSet{
            let minScale = scale.lowerBound
            let range = (scale.upperBound-scale.lowerBound)
            let ioPercentage = Float(ioValue)/Float(UInt16.max)
            logicalValue = minScale+(ioPercentage*range)
        }
    }
    public var logicalValue:Float = 0.0
    
    func setScale(_ scale:ClosedRange<Float>, unit:String){
        self.scale = scale
        self.unit = unit
    }
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.analogIn, channelNumber: channelNumber)
    }
}

@available(OSX 10.12, *)
public class AnalogOutputSignal:IOsignal{
    
    public var scale:ClosedRange<Float> = 0.0...100.0
    public var unit:String = "%"
    public var ioRange:ClosedRange<UInt16> = 0...UInt16.max
    
    public var scaledValue:Float = 0.0{
        didSet{
            let scaleSpan:Float = (scale.upperBound-scale.lowerBound)
            let percentage:Float = (scaledValue-scale.lowerBound)/scaleSpan
            
            let ioSpan:Float = Float(ioRange.upperBound-ioRange.lowerBound)
            ioValue = ioRange.lowerBound+UInt16(percentage*ioSpan)
        }
    }
    var ioValue:UInt16 = 0
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.analogOut, channelNumber: channelNumber)
    }
}

@available(OSX 10.12, *)
public class DigitalInputSignal:IOsignal{
    
    public enum digitalInputLogic{
        case straight
        case inverse
    }
    
    public var inputLogic: digitalInputLogic = .straight
    
    var ioValue:Bool = false{
        didSet{
            logicalValue = (inputLogic == .inverse) ? !ioValue : ioValue
        }
    }
    
    public var logicalValue:Bool = false
    
    init(channelNumber:Int, logic:digitalInputLogic = .straight) {
        super.init(channelType: ModbusIOtype.digitalIn, channelNumber: channelNumber)
        inputLogic = logic
    }
}

@available(OSX 10.12, *)
public class DigitalOutputSignal:IOsignal{
    
    public enum digitalOutputLogic{
        case straight
        case inverse
    }
    
    public var outputLogic: digitalOutputLogic = .straight
    
    public  var logicalValue:Bool = false
    {
        didSet{
            ioValue = (outputLogic == .inverse) ? !logicalValue : logicalValue
        }
    }
    
    internal var ioValue:Bool = false
    
    init(channelNumber:Int, logic:digitalOutputLogic = .straight) {
        super.init(channelType: ModbusIOtype.digitalOut, channelNumber: channelNumber)
        outputLogic = logic
    }
    
}


