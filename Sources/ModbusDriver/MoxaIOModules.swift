//
//  MoxaIOModules.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus

public class ioLogikE1200Series:IOmodule{
    
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

public class ioLogicE1240:ioLogikE1200Series{
    
    //8 Ains
    init(ipAddress:String, port:Int){
        super.init(ipAddress: ipAddress, port: port, channelCount: 8, ioType: IOmodule.modBusIOtype.analogIn)
    }
    
}

public class ioLogicE1241:ioLogikE1200Series{
    
    //4 Aouts
    init(ipAddress:String, port:Int){
        super.init(ipAddress: ipAddress, port: port, channelCount: 4, ioType: IOmodule.modBusIOtype.analogOut)
    }
    
}

public class ioLogicE1210:ioLogikE1200Series{
    
    //16 Dins
    init(ipAddress:String, port:Int){
        super.init(ipAddress: ipAddress, port: port, channelCount: 16, ioType: IOmodule.modBusIOtype.digitalIn)
    }
    
}

public class ioLogicE1216:ioLogikE1200Series{
    
    //16 Douts
    init(ipAddress:String, port:Int){
        super.init(ipAddress: ipAddress, port: port, channelCount: 16, ioType: IOmodule.modBusIOtype.digitalOut)
    }
}
