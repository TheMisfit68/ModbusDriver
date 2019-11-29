//
//  MoxaIOModules.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus

public class ioLogikE1200Series:IOmodule{
    
    let modbusDriver: ModbusDriver
    init(ipAddress:String, port:Int, channels:[IOsignal]){
        modbusDriver = ModbusDriver(ipAddress: ipAddress, port: port)
        super.init(channels: channels)
        
        modbusDriver.modules.append(self)
    }
    
}

public class ioLogicE1240:ioLogikE1200Series{
    
    //8 Ains
    init(ipAddress:String, port:Int){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...7{
            let ioChannel = AnalogInputsignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
    
}

public class ioLogicE1241:ioLogikE1200Series{
    
    //4 Aouts
    init(ipAddress:String, port:Int){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...3{
            let ioChannel = AnalogOutputsignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
    
}

public class ioLogicE1210:ioLogikE1200Series{
    
    //16 Dins
    init(ipAddress:String, port:Int){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...15{
            let ioChannel = DigitalInputsignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
    
}

public class ioLogicE1216:ioLogikE1200Series{
    
    //16 Douts
    init(ipAddress:String, port:Int){
        var ioChannels:[IOsignal] = []
        for channelNumber in 0...15{
            let ioChannel = DigitalOutputsignal(channelNumber: channelNumber)
            ioChannels.append(ioChannel)
        }
        super.init(ipAddress: ipAddress, port: port, channels:ioChannels)
    }
}
