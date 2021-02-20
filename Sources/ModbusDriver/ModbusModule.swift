//
//  ModbusModule.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus
import IOTypes

public class ModbusModule:IOModule{
	
    private var addressOffset:Int

    
    init(racknumber:Int = 0, slotNumber:Int = 0, channels:[IOSignal], addressOffset:Int = 0){
        
		self.addressOffset = addressOffset
		super.init(racknumber: racknumber, slotNumber:slotNumber, channels:channels)
        
    }
    
    func readAllInputs(connection modbus:OpaquePointer, pageStart:Int=0)->ModbusError{
        
        for analogRange in self.analogInRanges{
            
            let addressStart:Int32 = Int32(pageStart)+Int32(addressOffset)+Int32(analogRange.lowerBound)
            let length:Int32 = Int32(analogRange.count)
            let ioValues:UnsafeMutablePointer<UInt16> =  UnsafeMutablePointer<UInt16>.allocate(capacity: analogRange.count)
            
            let readResult = modbus_read_input_registers(modbus,addressStart, length, ioValues)
            guard readResult == analogRange.count else{
				status = .busFailure
                return .readError
            }
            
            for channelNumber in analogRange{
                let ioSignal = channels[channelNumber] as! AnalogInputSignal
				ioSignal.ioValue = (status != .busFailure ? ioValues[channelNumber] : nil)
            }
            
        }
        
        for digitalRange in self.digitalInRanges{
            
            let addressStart:Int32 = Int32(pageStart)+Int32(addressOffset)+Int32(digitalRange.lowerBound)
            let length:Int32 = Int32(digitalRange.count)
            let ioValues:UnsafeMutablePointer<UInt8> =  UnsafeMutablePointer<UInt8>.allocate(capacity: digitalRange.count)
            
            let readResult = modbus_read_input_bits(modbus, addressStart, length, ioValues)
			guard readResult == digitalRange.count else{
				status = .busFailure
                return .readError
            }
            for channelNumber in digitalRange{
                let ioSignal = channels[channelNumber] as! DigitalInputSignal
                ioSignal.ioValue = (status != .busFailure ? (ioValues[channelNumber] > 0) : nil)
            }
            
        }
        
        return .noError
    }
    
    func writeAllOutputs(connection modbus:OpaquePointer, addressPage:Int=0)->ModbusError{
        
        for analogRange in self.analogOutRanges{
            
            let addressStart:Int32 = Int32(addressPage)+Int32(addressOffset)+Int32(analogRange.lowerBound)
            let length:Int32 = Int32(analogRange.count)
            let ioValues:UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: analogRange.count)
            
            for channelNumber in analogRange{
                let ioSignal = channels[channelNumber] as! AnalogOutputSignal
                ioValues[channelNumber] = ioSignal.ioValue
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
			
            for channelNumber in digitalRange{
                let ioSignal = channels[channelNumber] as! DigitalOutputSignal
                ioValues[channelNumber] = ioSignal.ioValue ? 1 : 0
            }
            let writeResult = modbus_write_bits(modbus, addressStart, length, ioValues)
			guard writeResult == digitalRange.count else{
				status = .busFailure
                return .writeError
            }
			
        }
        
        return .noError
    }
	
	func readAllOutputs(connection modbus:OpaquePointer, pageStart:Int=0)->ModbusError{
		
		for analogRange in self.analogOutRanges{
			
			let addressStart:Int32 = Int32(pageStart)+Int32(addressOffset)+Int32(analogRange.lowerBound)
			let length:Int32 = Int32(analogRange.count)
			let ioFeedbackValues:UnsafeMutablePointer<UInt16> =  UnsafeMutablePointer<UInt16>.allocate(capacity: analogRange.count)
			
			let readResult = modbus_read_input_registers(modbus,addressStart, length, ioFeedbackValues)
			guard readResult == analogRange.count else{
				status = .busFailure
				return .readError
			}
			
			for channelNumber in analogRange{
				let ioSignal = channels[channelNumber] as! AnalogOutputSignal
				ioSignal.ioFeedbackValue = (status != .busFailure ? ioFeedbackValues[channelNumber] : nil)
			}
			
		}
		
		for digitalRange in self.digitalOutRanges{
			
			let addressStart:Int32 = Int32(pageStart)+Int32(addressOffset)+Int32(digitalRange.lowerBound)
			let length:Int32 = Int32(digitalRange.count)
			let ioFeedbackValues:UnsafeMutablePointer<UInt8> =  UnsafeMutablePointer<UInt8>.allocate(capacity: digitalRange.count)
			
			let readResult = modbus_read_input_bits(modbus, addressStart, length, ioFeedbackValues)
			guard readResult == digitalRange.count else{
				status = .busFailure
				return .readError
			}
			for channelNumber in digitalRange{
				let ioSignal = channels[channelNumber] as! DigitalOutputSignal
				ioSignal.ioFeedbackValue = (status != .busFailure ? (ioFeedbackValues[channelNumber] > 0) : nil)
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
