//
//  IOModule.swift
//  
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import ClibModbus

public class IOmodule{
    
    let slotNumber:Int
    let channels: [IOsignal]
    
    var analogIns:[IOsignal]
    var analogOuts:[IOsignal]
    var digitalIns:[IOsignal]
    var digitalOuts:[IOsignal]
    
    init(slotNumber:Int = 0, channels:[IOsignal]){
        self.slotNumber = slotNumber
        self.channels = channels
        
        // Keep different type channels seperated and sorted for optimum access later
        self.analogIns = channels.filter {$0.ioType == .analogIn}
        self.analogOuts = channels.filter {$0.ioType == .analogIn}
        self.digitalIns = channels.filter {$0.ioType == .digitalIn}
        self.digitalOuts = channels.filter {$0.ioType == .digitalOut}
        
        self.analogIns.sort {$0.number < $1.number}
        self.analogOuts.sort {$0.number < $1.number}
        self.digitalIns.sort {$0.number < $1.number}
        self.analogOuts.sort {$0.number < $1.number}
        
        let consecutiveRange = self.analogIns.enumerated().filter {self.analogIns[$0.offset].number+1 != self.analogIns[$0.offset+1].number}
        if consecutiveRange.count  > 0 {
            print("ranges: \(consecutiveRange)")
        }
    }
    
    func readAllInputs(){
    }
    
    func writeAllOutputs(){
        
    }
    
    private func swiftArray(_arrayPointer:UnsafeMutablePointer<UInt8>)->[UInt8]{
        var nativeArray:[UInt8] = []
        for n in 0...15 {
            nativeArray.append(_arrayPointer[n])
        }
        return nativeArray
    }
    

    
}
