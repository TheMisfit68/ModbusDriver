//
//  MoxaModules.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus
import IOTypes

@ModbusActor public class IOLogikE1200Series:ModbusModule{
    
    // IOLogikE1200Series each have their own IP-address and therefore need their own driver
    public let driver: ModbusDriver
    
    public init(ipAddress:String, port:Int, channels:[ModbusSignal], addressOffset:Int = 0){
        driver = ModbusDriver(ipAddress: ipAddress, port: port)
        super.init(channels: channels, addressOffset:addressOffset)
        
        driver.modbusModules.append(self)
    }
    
}

// MARK: - 8 Ains
public class IOLogicE1240:IOLogikE1200Series{
    
    public init(ipAddress:String, port:Int=502){
        var ioChannels:[ModbusSignal] = []
        for channelNumber in 0...7{
            let ioChannel = AnalogInputSignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
    
}

// MARK: - 4 Aouts
public class IOLogicE1241:IOLogikE1200Series{

    public init(ipAddress:String, port:Int=502){
        var ioChannels:[ModbusSignal] = []
        for channelNumber in 0...3{
            let ioChannel = AnalogOutputSignal(channelNumber: channelNumber)
            ioChannel.ioRange = 0...4095
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels, addressOffset: 1024)
    }
    
}

// MARK: - 16 Dins
public class IOLogicE1210:IOLogikE1200Series{

    public init(ipAddress:String, port:Int=502){
        var ioChannels:[ModbusSignal] = []
        for channelNumber in 0...15{
            let ioChannel = DigitalInputSignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
    
}

// MARK: - 16 Douts
public class IOLogicE1211:IOLogikE1200Series{
    
    public init(ipAddress:String, port:Int=502){
        var ioChannels:[ModbusSignal] = []
        for channelNumber in 0...15{
            let ioChannel = DigitalOutputSignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
}
