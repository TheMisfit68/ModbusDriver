//
//  MoxaIOModules.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus

class ioLogikE1200Series:IOmodule{
    
    let ipAddress:String
    let portNumber:Int
    
    init(ipAddress:String, port:Int, channelCount:Int, ioType:modBusIOtype){
        
        self.ipAddress = ipAddress
        self.portNumber = port
        super.init(channelCount: channelCount, ioType: ioType)
    }
    
    func connect(){
        let mb = modbus_new_tcp(ipAddress, Int32(portNumber));
        modbus_connect(mb);
    }
    
}

class ioLogicE1240:ioLogikE1200Series{
    
    //8 Ains
    init(ipAddress:String, port:Int){
        super.init(ipAddress: ipAddress, port: port, channelCount: 8, ioType: IOmodule.modBusIOtype.analogIn)
    }
    
}

class ioLogicE1241:ioLogikE1200Series{
    
    //4 Aouts
    init(ipAddress:String, port:Int){
        super.init(ipAddress: ipAddress, port: port, channelCount: 4, ioType: IOmodule.modBusIOtype.analogOut)
    }
    
}

class ioLogicE1210:ioLogikE1200Series{
    
    //16 Dins
    init(ipAddress:String, port:Int){
        super.init(ipAddress: ipAddress, port: port, channelCount: 16, ioType: IOmodule.modBusIOtype.digitalIn)
    }
    
}

class ioLogicE1216:ioLogikE1200Series{
    
    //16 Douts
    init(ipAddress:String, port:Int){
        super.init(ipAddress: ipAddress, port: port, channelCount: 16, ioType: IOmodule.modBusIOtype.digitalOut)
    }
}
