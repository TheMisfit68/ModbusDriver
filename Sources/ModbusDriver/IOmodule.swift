//
//  IOModule.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus

@available(OSX 10.12, *)
public class IOmodule{
    
    public let slotNumber:Int
    public var channels: [IOsignal]
    private var addressOffset:Int32
    
    var analogInRanges:[ClosedRange<Int>] = []
    var analogOutRanges:[ClosedRange<Int>] = []
    var digitalInRanges:[ClosedRange<Int>] = []
    var digitalOutRanges:[ClosedRange<Int>] = []
    
    init(slotNumber:Int = 0, channels:[IOsignal], addressOffset:Int32 = 0){
        
        self.slotNumber = slotNumber
        self.channels = channels
        self.addressOffset = addressOffset
                
        // Store consecutive ranges for different type channels, for optimum access later
        self.analogInRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .analogIn})
        self.analogOutRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .analogOut})
        self.digitalInRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .digitalIn})
        self.digitalOutRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .digitalOut})
        
  

    }
    
    func readAllInputs(connection modbus:OpaquePointer){
        
        for analogRange in self.analogInRanges{
            let ioValues:UnsafeMutablePointer<UInt16> =  UnsafeMutablePointer<UInt16>.allocate(capacity: analogRange.count)
            modbus_read_input_registers(modbus,addressOffset+Int32(analogRange.lowerBound), Int32(analogRange.count), ioValues)
            for channelNumber in analogRange{
                let ioSignal = channels[channelNumber] as! AnalogInputSignal
                ioSignal.ioValue = ioValues[channelNumber]
            }
        }
        
        for digitalRange in self.digitalInRanges{
            let ioValues:UnsafeMutablePointer<UInt8> =  UnsafeMutablePointer<UInt8>.allocate(capacity: digitalRange.count)
            modbus_read_input_bits(modbus, addressOffset+Int32(digitalRange.lowerBound), Int32(digitalRange.count), ioValues)
            for channelNumber in digitalRange{
                let ioSignal = channels[channelNumber] as! DigitalInputSignal
                ioSignal.ioValue = (ioValues[channelNumber]) > 0 ? true : false
            }
        }
        
    }
    
    func writeAllOutputs(connection modbus:OpaquePointer){
        
        for analogRange in self.analogOutRanges{
            let ioValues:UnsafeMutablePointer<UInt16> = UnsafeMutablePointer<UInt16>.allocate(capacity: analogRange.count)
            for channelNumber in analogRange{
                let ioSignal = channels[channelNumber] as! AnalogOutputSignal
                ioValues[channelNumber] = ioSignal.ioValue
            }
            modbus_write_registers(modbus, addressOffset+Int32(analogRange.lowerBound), Int32(analogRange.count), ioValues)
        }
        
        for digitalRange in self.digitalOutRanges{
            let ioValues:UnsafeMutablePointer<UInt8> =  UnsafeMutablePointer<UInt8>.allocate(capacity: digitalRange.count)
            for channelNumber in digitalRange{
                let ioSignal = channels[channelNumber] as! DigitalOutputSignal
                ioValues[channelNumber] = ioSignal.ioValue ? 1 : 0
            }
            modbus_write_bits(modbus, addressOffset+Int32(digitalRange.lowerBound), Int32(digitalRange.count), ioValues)
        }
        
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
