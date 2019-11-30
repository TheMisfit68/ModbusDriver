//
//  MoxaIOModules.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus

public class ioLogikE1200Series:IOmodule{
    
    public let modbusDriver: ModbusDriver
    public init(ipAddress:String, port:Int, channels:[IOsignal]){
        modbusDriver = ModbusDriver(ipAddress: ipAddress, port: port)
        super.init(channels: channels)
        
        modbusDriver.modules.append(self)
    }
    
}

public class ioLogicE1240:ioLogikE1200Series{
    
    //8 Ains
    public init(ipAddress:String, port:Int){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...7{
            let ioChannel = AnalogInputSignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
    
}

public class ioLogicE1241:ioLogikE1200Series{
    
    //4 Aouts
    public init(ipAddress:String, port:Int){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...3{
            let ioChannel = AnalogOutputSignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
    
}

public class ioLogicE1210:ioLogikE1200Series{
    
    //16 Dins
    public init(ipAddress:String, port:Int){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...15{
            let ioChannel = DigitalInputSignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
    
}

public class ioLogicE1216:ioLogikE1200Series{
    
    //16 Douts
    public init(ipAddress:String, port:Int){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...15{
            let ioChannel = DigitalOutputSignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
}
