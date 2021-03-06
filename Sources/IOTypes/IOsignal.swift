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
	
	var scale:ClosedRange<Float> = 0.0...100.0
	var unit:String = ""
	
	public var logicalValue:Float?
	
	func setScale(_ scale:ClosedRange<Float>, unit:String){
		self.scale = scale
		self.unit = unit
	}
	
	public init(channelNumber:Int) {
		super.init(channelType: IOType.analogIn, channelNumber: channelNumber)
	}
	
	public var ioValue:UInt16?{
		didSet{
			guard ioValue != nil else{ logicalValue = nil; return }
			
			let minScale = scale.lowerBound
			let range = (scale.upperBound-scale.lowerBound)
			let ioPercentage = Float(ioValue!)/Float(UInt16.max)
			logicalValue = minScale+(ioPercentage*range)
			
		}
	}
}

open class AnalogOutputSignal:IOSignal{
	
	public var scale:ClosedRange<Float> = 0.0...100.0
	public var unit:String = "%"
	public var ioRange:ClosedRange<UInt16> = 0...UInt16.max
	
	public var scaledValue:Float = 0{
		didSet{
			
			let scaleSpan:Float = (scale.upperBound-scale.lowerBound)
			let percentage:Float = (scaledValue-scale.lowerBound)/scaleSpan
			
			let ioSpan:Float = Float(ioRange.upperBound-ioRange.lowerBound)
			ioValue = ioRange.lowerBound+UInt16(percentage*ioSpan)
			
		}
	}
	public var scaledFeedBackValue:Float?
	
	public init(channelNumber:Int) {
		super.init(channelType: IOType.analogOut, channelNumber: channelNumber)
	}
	
	public var ioValue:UInt16 = 0
	
	public var ioFeedbackValue:UInt16?{
		didSet{
			guard ioFeedbackValue != nil else{ scaledFeedBackValue = nil; return }
			
			let ioSpan:Float = Float(ioRange.upperBound-ioRange.lowerBound)
			let percentage:Float = Float(ioFeedbackValue!-ioRange.lowerBound)/ioSpan
			
			let scaleSpan:Float = (scale.upperBound-scale.lowerBound)

			scaledFeedBackValue = scale.lowerBound+(percentage*scaleSpan)
		}
	}
}

open class DigitalInputSignal:IOSignal{
	
	public enum digitalInputLogic{
		case straight
		case inverse
	}
	
	public var inputLogic: digitalInputLogic = .straight
	
	public var logicalValue:Bool?
	
	public init(channelNumber:Int, logic:digitalInputLogic = .straight) {
		super.init(channelType: IOType.digitalIn, channelNumber: channelNumber)
		inputLogic = logic
	}
	
	public var ioValue:Bool?{
		didSet{
			guard ioValue != nil else{ logicalValue = nil; return }
			
			logicalValue = (inputLogic == .inverse) ? !ioValue! : ioValue!
		}
	}
}

open class DigitalOutputSignal:IOSignal{
	
	public enum digitalOutputLogic{
		case straight
		case inverse
	}
	
	public var outputLogic: digitalOutputLogic = .straight
	
	public var logicalValue:Bool = false{
		didSet{
			ioValue = (outputLogic == .inverse) ? !logicalValue : logicalValue
		}
	}
	public var logicalFeedbackValue:Bool?
	
	public init(channelNumber:Int, logic:digitalOutputLogic = .straight) {
		super.init(channelType: IOType.digitalOut, channelNumber: channelNumber)
		outputLogic = logic
	}
	
	public var ioValue:Bool = false
	
	public var ioFeedbackValue:Bool?{
		didSet{
			guard ioFeedbackValue != nil else{ logicalFeedbackValue = nil; return }
			
			logicalFeedbackValue = (outputLogic == .inverse) ? !ioFeedbackValue! : ioFeedbackValue!
		}
	}
	
}


