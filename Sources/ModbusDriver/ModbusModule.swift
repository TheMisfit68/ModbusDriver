//
//  ModbusModule.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import IOTypes
import ClibModbus

public typealias ModbusSignal = IOSignal

public class ModbusModule:IOModule{
	
	private var addressOffset:Int
	
	init(racknumber:Int = 0, slotNumber:Int = 0, channels:[ModbusSignal], addressOffset:Int = 0){
		
		self.addressOffset = addressOffset
		super.init(rackNumber: racknumber, slotNumber:slotNumber, channels:channels)
		
	}
	
	
	func readAllInputs(connection modbus:OpaquePointer, pageStart:Int=0)->ModbusError{
		
		for analogRange in self.analogInRanges{
			
			let addressStart:Int32 = Int32(pageStart)+Int32(addressOffset)+Int32(analogRange.lowerBound)
			let length:Int32 = Int32(analogRange.count)
			let ioValues:UnsafeMutablePointer<UInt16> =  UnsafeMutablePointer<UInt16>.allocate(capacity: analogRange.count)
			defer {
				ioValues.deallocate()
			}
			
			let readResult = modbus_read_input_registers(modbus,addressStart, length, ioValues)
			guard readResult == analogRange.count else{
				status = .busFailure
				return .readError
			}
			
			for channelNumber in analogRange{
				if let modbusSignal = channels[channelNumber] as? AnalogInputSignal {
					modbusSignal.ioValue = (status != .busFailure ? ioValues[channelNumber] : nil)
				}
			}
			
		}
		
		for digitalRange in self.digitalInRanges{
			
			let addressStart:Int32 = Int32(pageStart)+Int32(addressOffset)+Int32(digitalRange.lowerBound)
			let length:Int32 = Int32(digitalRange.count)
			let ioValues:UnsafeMutablePointer<UInt8> =  UnsafeMutablePointer<UInt8>.allocate(capacity: digitalRange.count)
			defer {
				ioValues.deallocate()
			}
			
			let readResult = modbus_read_input_bits(modbus, addressStart, length, ioValues)
			guard readResult == digitalRange.count else{
				status = .busFailure
				return .readError
			}
			for channelNumber in digitalRange{
				if let modbusSignal = channels[channelNumber] as? DigitalInputSignal{
					modbusSignal.ioValue = (status != .busFailure ? (ioValues[channelNumber] > 0) : nil)
				}
			}
			
		}
		
		return .noError
	}
	
	
	func readAllOutputs(connection modbus:OpaquePointer, pageStart:Int=0)->ModbusError{
		
		for analogRange in self.analogOutRanges{
			
			let addressStart:Int32 = Int32(pageStart)+Int32(addressOffset)+Int32(analogRange.lowerBound)
			let length:Int32 = Int32(analogRange.count)
			let ioFeedbackValues:UnsafeMutablePointer<UInt16> =  UnsafeMutablePointer<UInt16>.allocate(capacity: analogRange.count)
			defer {
				ioFeedbackValues.deallocate()
			}
			
			let readResult = modbus_read_registers(modbus,addressStart, length, ioFeedbackValues)
			guard readResult == analogRange.count else{
				status = .busFailure
				return .readError
			}
			
			for channelNumber in analogRange{
				if let modbusSignal = channels[channelNumber] as? AnalogOutputSignal{
					let firstRun:Bool = modbusSignal.ioFeedbackValue == nil
					modbusSignal.ioFeedbackValue = ioFeedbackValues[channelNumber]
					if firstRun, let scaledFeedback = modbusSignal.scaledFeedBackValue{
						modbusSignal.scaledValue = scaledFeedback
					}
				}
			}
			
		}
		
		for digitalRange in self.digitalOutRanges{
			
			let addressStart:Int32 = Int32(pageStart)+Int32(addressOffset)+Int32(digitalRange.lowerBound)
			let length:Int32 = Int32(digitalRange.count)
			let ioFeedbackValues:UnsafeMutablePointer<UInt8> =  UnsafeMutablePointer<UInt8>.allocate(capacity: digitalRange.count)
			defer {
				ioFeedbackValues.deallocate()
			}
			
			let readResult = modbus_read_bits(modbus, addressStart, length, ioFeedbackValues)
			guard readResult == digitalRange.count else{
				status = .busFailure
				return .readError
			}
			for channelNumber in digitalRange{
				if let modbusSignal = channels[channelNumber] as? DigitalOutputSignal{
					let firstRun:Bool = modbusSignal.ioFeedbackValue == nil
					modbusSignal.ioFeedbackValue = (ioFeedbackValues[channelNumber] > 0)
					if firstRun, let logicalFeedback = modbusSignal.logicalFeedbackValue{
						modbusSignal.logicalValue = logicalFeedback
					}
				}
			}
			
		}
		
		return .noError
	}
	
	
	func writeAllOutputs(connection modbus:OpaquePointer, addressPage:Int=0)->ModbusError{
		
		for analogRange in self.analogOutRanges{
			
			let addressStart:Int32 = Int32(addressPage)+Int32(addressOffset)+Int32(analogRange.lowerBound)
			let length:Int32 = Int32(analogRange.count)
			let ioValues:UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: analogRange.count)
			defer {
				ioValues.deallocate()
			}
			
			for channelNumber in analogRange{
				if let modbusSignal = channels[channelNumber] as? AnalogOutputSignal{
					let ioValue = modbusSignal.ioValue
					ioValues[channelNumber] = ioValue
				}
			}
			let writeResult = modbus_write_registers(modbus, addressStart, length, ioValues)
			guard writeResult == analogRange.count else{
				status = .busFailure
				return .writeError
			}
			
		}
		
		for digitalRange in self.digitalOutRanges{
			
			let addressStart:Int32 = Int32(addressPage)+Int32(addressOffset)+Int32(digitalRange.lowerBound)
			let length:Int32 = Int32(digitalRange.count)
			let ioValues:UnsafeMutablePointer<UInt8> =  UnsafeMutablePointer<UInt8>.allocate(capacity: digitalRange.count)
			defer {
				ioValues.deallocate()
			}
			
			for channelNumber in digitalRange{
				if let modbusSignal = channels[channelNumber] as? DigitalOutputSignal{
					let ioValue = modbusSignal.ioValue
					ioValues[channelNumber] = ioValue ? 1 : 0
				}
			}
			let writeResult = modbus_write_bits(modbus, addressStart, length, ioValues)
			guard writeResult == digitalRange.count else{
				status = .busFailure
				return .writeError
			}
		}
		
		return .noError
	}
	
	
	private func swiftArray(_arrayPointer:UnsafeMutablePointer<UInt8>)->[UInt8]{
		var nativeArray:[UInt8] = []
		for n in 0...15 {
			nativeArray.append(_arrayPointer[n])
		}
		return nativeArray
	}
	
	
}
