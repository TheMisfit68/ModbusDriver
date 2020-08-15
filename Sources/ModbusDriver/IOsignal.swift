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
    
    public var scaledFeedbackValue:Float? = nil
    public var scaledValue:Float = 0.0{
        didSet{
            let scaleSpan:Float = (scale.upperBound-scale.lowerBound)
            let percentage:Float = (scaledValue-scale.lowerBound)/scaleSpan
            
            let ioSpan:Float = Float(ioRange.upperBound-ioRange.lowerBound)
            ioValue = ioRange.lowerBound+UInt16(percentage*ioSpan)
        }
    }
    public var scaledBackupValue:Float? = nil
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
    
    public var logicalValue:Bool =  false
    private var memoryBit: Bool = false
    
    var ioValue:Bool = false{
        didSet{
            logicalValue = (inputLogic == .inverse) ? !ioValue : ioValue
            memoryBit = logicalValue
        }
    }
    
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
    public var logicalFeedbackValue:Bool? = false
    internal var ioValue:Bool = false
    
    public var risingEdge:Bool = false
    public var falingEdge:Bool = false
    
    public  var logicalValue:Bool = false{
        
        didSet{
            self.risingEdge = logicalValue && !oldValue
            self.falingEdge = !logicalValue && oldValue
            
            if logicalValue != oldValue{
                
                // Update the IO-value to represent the changed logical value
                switch outputType {
                case .level:
                    let level:Bool = logicalValue
                    ioValue = (outputLogic == .inverse) ? !level : level
                case let .pulse(pulsLength):
                    let puls:Bool = logicalValue
                    ioValue = (outputLogic == .inverse) ? !puls : puls
                    limitIOpuls(to: pulsLength)
                case let .toggle(pulsLength):
                    var togglePuls:Bool = logicalValue
                    if let logicalFeedbackValue = logicalFeedbackValue, logicalValue == logicalFeedbackValue{
                        togglePuls = false
                    }
                    ioValue = (outputLogic == .inverse) ? !togglePuls : togglePuls
                    limitIOpuls(to: pulsLength)
                }
                
            }
        }
    }
    
    init(channelNumber:Int) {
        super.init(channelType: ModbusIOtype.digitalOut, channelNumber: channelNumber)
    }
    
    private func limitIOpuls(to length:Double){
        if risingEdge{
            // Reset the IO after the given pulsLength (to the equivalent of logical false)
            DispatchQueue.main.asyncAfter(deadline: .now() + length) {
                self.ioValue = (self.outputLogic == .inverse) ?  true : false
            }
        }
    }
}


