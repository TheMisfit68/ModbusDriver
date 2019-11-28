//
//  ModbusIOModule.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus

public class IOmodule{
    
    enum modBusIOtype{
        case analogIn
        case analogOut
        case digitalIn
        case digitalOut
    }
    
    let numberOfChannels:Int
    let ioType: modBusIOtype

    init(channelCount:Int, ioType:modBusIOtype){
        self.numberOfChannels = channelCount
        self.ioType = ioType
    }

    
}
