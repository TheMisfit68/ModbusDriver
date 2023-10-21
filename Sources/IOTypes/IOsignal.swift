//
//  IOSignal.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation

public enum IOType{
	case analogIn
	case analogOut
	case digitalIn
	case digitalOut
}

open class IOSignal{
	
	public var ioType:IOType
	public var number:Int
	
	init(channelType:IOType, channelNumber:Int){
		self.ioType = channelType
		self.number = channelNumber
	}
	
}

open class AnalogInputSignal:IOSignal{
	
	public var ioValue:UInt16?
	public var ioRange:ClosedRange<UInt16> = 0...UInt16.max
	var scale:ClosedRange<Float> = 0.0...100.0
	var unit:String = ""
	public var scaledValue:Float?{
		guard ioValue != nil else{ return nil}
		
		let ioSpan:Float = Float(ioRange.upperBound-ioRange.lowerBound)
		let percentage = Float(ioValue!-ioRange.lowerBound)/ioSpan
		
		let scaleSpan:Float = (scale.upperBound-scale.lowerBound)
		return scale.lowerBound+(percentage*scaleSpan)
	}
	
	func setScale(_ scale:ClosedRange<Float>, unit:String){
		self.scale = scale
		self.unit = unit
	}
	
	public init(channelNumber:Int) {
		super.init(channelType: IOType.analogIn, channelNumber: channelNumber)
	}
	
	
}

open class AnalogOutputSignal:IOSignal{
	
	public var scaledValue:Float = 0
	public var scale:ClosedRange<Float> = 0.0...100.0
	public var unit:String = "%"
	public var ioRange:ClosedRange<UInt16> = 0...UInt16.max
	public var ioValue:UInt16{
		
		let scaleSpan:Float = (scale.upperBound-scale.lowerBound)
		let percentage:Float = (scaledValue-scale.lowerBound)/scaleSpan
		
		let ioSpan:Float = Float(ioRange.upperBound-ioRange.lowerBound)
		return ioRange.lowerBound+UInt16(percentage*ioSpan)
		
	}
	
	public var ioFeedbackValue:UInt16?
	public var scaledFeedBackValue:Float?{
		guard ioFeedbackValue != nil else{ return nil}
		
		let ioSpan:Float = Float(ioRange.upperBound-ioRange.lowerBound)
		let percentage:Float = Float(ioFeedbackValue!-ioRange.lowerBound)/ioSpan
		
		let scaleSpan:Float = (scale.upperBound-scale.lowerBound)
		return scale.lowerBound+(percentage*scaleSpan)
	}
	
	public init(channelNumber:Int) {
		super.init(channelType: IOType.analogOut, channelNumber: channelNumber)
	}
	
}

open class DigitalInputSignal:IOSignal{
	
	public enum digitalInputLogic{
		case straight
		case inverse
	}
	
	public var ioValue:Bool?
	public var inputLogic: digitalInputLogic = .straight
	public var logicalValue:Bool?{
		guard ioValue != nil else{ return  nil}
		return (inputLogic == .inverse) ? !ioValue! : ioValue!
	}
	
	public init(channelNumber:Int, logic:digitalInputLogic = .straight) {
		super.init(channelType: IOType.digitalIn, channelNumber: channelNumber)
		inputLogic = logic
	}
	
	
}

open class DigitalOutputSignal:IOSignal{
	
	public enum digitalOutputLogic{
		case straight
		case inverse
	}
	
	public var outputLogic: digitalOutputLogic = .straight
	
	public var logicalValue:Bool = false
	public var ioValue:Bool{
		return (outputLogic == .inverse) ? !logicalValue : logicalValue
	}
	
	public var ioFeedbackValue:Bool?
	public var logicalFeedbackValue:Bool?{
		guard ioFeedbackValue != nil else{ return nil}
		return (outputLogic == .inverse) ? !ioFeedbackValue! : ioFeedbackValue!
	}
	
	public init(channelNumber:Int, logic:digitalOutputLogic = .straight) {
		super.init(channelType: IOType.digitalOut, channelNumber: channelNumber)
		outputLogic = logic
	}
	
}
