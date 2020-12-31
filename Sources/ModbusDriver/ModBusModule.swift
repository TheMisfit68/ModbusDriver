//
//  ModbusModule.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus
public class ModBusModule{
    
    public let rackNumber:Int
    public let slotNumber:Int
    public var channels: [IOsignal]
    private var addressOffset:Int
    
    var analogInRanges:[ClosedRange<Int>] = []
    var analogOutRanges:[ClosedRange<Int>] = []
    var digitalInRanges:[ClosedRange<Int>] = []
    var digitalOutRanges:[ClosedRange<Int>] = []
    
    init(racknumber:Int = 0, slotNumber:Int = 0, channels:[IOsignal], addressOffset:Int = 0){
        
        self.rackNumber = racknumber
        self.slotNumber = slotNumber
        self.channels = channels
        self.addressOffset = addressOffset
        
        // Store consecutive ranges for different type channels, for optimum access later
        self.analogInRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .analogIn})
        self.analogOutRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .analogOut})
        self.digitalInRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .digitalIn})
        self.digitalOutRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .digitalOut})
        
    }
    
    func readAllInputs(connection modbus:OpaquePointer, pageStart:Int=0)->ModbusError{
        
        for analogRange in self.analogInRanges{
            
            let addressStart:Int32 = Int32(pageStart)+Int32(addressOffset)+Int32(analogRange.lowerBound)
            let length:Int32 = Int32(analogRange.count)
            let ioValues:UnsafeMutablePointer<UInt16> =  UnsafeMutablePointer<UInt16>.allocate(capacity: analogRange.count)
            
            let readResult = modbus_read_input_registers(modbus,addressStart, length, ioValues)
            if(readResult != analogRange.count){
                return .readError
            }
            
            for channelNumber in analogRange{
                let ioSignal = channels[channelNumber] as! AnalogInputSignal
                ioSignal.ioValue = ioValues[channelNumber]
            }
            
        }
        
        for digitalRange in self.digitalInRanges{
            
            let addressStart:Int32 = Int32(pageStart)+Int32(addressOffset)+Int32(digitalRange.lowerBound)
            let length:Int32 = Int32(digitalRange.count)
            let ioValues:UnsafeMutablePointer<UInt8> =  UnsafeMutablePointer<UInt8>.allocate(capacity: digitalRange.count)
            
            let readResult = modbus_read_input_bits(modbus, addressStart, length, ioValues)
            if(readResult != digitalRange.count){
                return .readError
            }
            for channelNumber in digitalRange{
                let ioSignal = channels[channelNumber] as! DigitalInputSignal
                ioSignal.ioValue = (ioValues[channelNumber]) > 0 ? true : false
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
            if writeResult != analogRange.count{
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
            if writeResult != digitalRange.count{
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
    
    private func consecutiveRanges(signals:[IOsignal])->[ClosedRange<Int>]{
        let sortedSignals = signals.sorted(by: { $0.number < $1.number })
        var consecutiveRanges:[ClosedRange<Int>] = []
        var lowerBound:Int? = nil
        var upperBound:Int? = nil
        for (index, item) in sortedSignals.enumerated(){
            
            if (index == 0) || (lowerBound == nil){
                lowerBound = item.number
            }
            if (index == sortedSignals.count-1) || (sortedSignals[index].number+1 < sortedSignals[index+1].number){
                upperBound = item.number
            }
            if (lowerBound != nil) && (upperBound != nil){
                consecutiveRanges.append(lowerBound!...upperBound!)
                upperBound = nil
                lowerBound =  nil
                
            }
        }
        return consecutiveRanges
    }
    
    
}
