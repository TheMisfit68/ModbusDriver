//
//  MoxaIOModules.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus



@available(OSX 10.12, *)
public class IOLogikE1200Series:IOmodule{
    
    public let driver: ModbusDriver
    public init(ipAddress:String, port:Int, channels:[IOsignal], addressOffset:Int32 = 0){
        driver = ModbusDriver(ipAddress: ipAddress, port: port)
        super.init(channels: channels, addressOffset:addressOffset)
        
        driver.ioModules.append(self)
    }
    
}

@available(OSX 10.12, *)
public class IOLogicE1240:IOLogikE1200Series{
    
    //8 Ains
    public init(ipAddress:String, port:Int=502){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...7{
            let ioChannel = AnalogInputSignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
    
}

@available(OSX 10.12, *)
public class IOLogicE1241:IOLogikE1200Series{
    
    // 4 Aouts
    public init(ipAddress:String, port:Int=502){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...3{
            let ioChannel = AnalogOutputSignal(channelNumber: channelNumber)
            ioChannel.ioRange = 0...4095
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels, addressOffset: 1024)
    }
    
}

@available(OSX 10.12, *)
public class IOLogicE1210:IOLogikE1200Series{
    
    //16 Dins
    public init(ipAddress:String, port:Int=502){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...15{
            let ioChannel = DigitalInputSignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
    
}

@available(OSX 10.12, *)
public class IOLogicE1211:IOLogikE1200Series{
    
    //16 Douts
    public init(ipAddress:String, port:Int=502){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...15{
            let ioChannel = DigitalOutputSignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
}
