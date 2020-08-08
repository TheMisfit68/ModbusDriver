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
    
    
    let scale:ClosedRange<Float> = 0.0...100.0
    let unit:String = "%"
    public var logicalValue:Float = 0.0{
        didSet{
            ioValue = UInt16(logicalValue/100.0*Float(UInt16.max))
        }
    }
    var ioValue:UInt16 = 0
    var feedbackSignal:AnalogInputSignal? = nil
    
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
    public var logicalValue:Bool =  false
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.digitalIn, channelNumber: channelNumber)
    }
}

@available(OSX 10.12, *)
public class DigitalOutputSignal:IOsignal{
    
    public enum digitalOutputType{
        case level
        case pulse(Double) // The number of seconds te puls should last
        case toggle(Double) // The number of seconds te puls should last
    }
    
    public enum digitalOutputLogic{
        case straight
        case inverse
    }
    
    public var outputType: digitalOutputType = .level
    public var outputLogic: digitalOutputLogic = .straight

    public var feedbackSignal:DigitalInputSignal? = nil
    public var logicalValue:Bool = false{
        didSet{
            
            switch outputType {
            case .level:
                ioValue = (outputLogic == .inverse) ? !logicalValue : logicalValue
            case let .pulse(pulsLength):
                ioValue = (outputLogic == .inverse) ? !logicalValue : logicalValue
                if logicalValue == true{
                    limitPulsLenghtTo(pulsLength)
                }
            case let .toggle(pulsLength):
                if let feedBackValue = feedbackSignal?.logicalValue, logicalValue == feedBackValue{
                    logicalValue = false
                }
                ioValue = (outputLogic == .inverse) ? !logicalValue : logicalValue
                if logicalValue == true{
                    limitPulsLenghtTo(pulsLength)
                }
            }
            
        }
    }
    
    internal var ioValue:Bool = false
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.digitalOut, channelNumber: channelNumber)
    }
    
    private func limitPulsLenghtTo(_ pulsLength:Double){
        // Reset the ouput to logical false after the given pulsLength
        DispatchQueue.main.asyncAfter(deadline: .now() + pulsLength) {
            self.ioValue = (self.outputLogic == .inverse) ?  true : false
        }
    }
    
}
