//
//  ModbusSimulator.swift
//
//
//  Created by Jan Verrept on 28/11/2019.
//

import ClibModbus
import Foundation

open class ModbusSimulator: ModbusDriver{
    
    private var addressPageSimulatorInputs = 0
    private var addressPageSimulatorOutputs = 0
    private let addressPageLengthPerModule = 100
    
    public override init(ipAddress:String = "127.0.0.1", port:Int = 502){
        super.init(ipAddress:ipAddress, port:port)
    }
    
	override func readInputModules() {
		addressPageSimulatorInputs = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulatorInputs*addressPageLengthPerModule
			
			let readResult = modbusModule.readAllInputs(connection: modbusConnection, pageStart:pageStart)
			guard readResult == .noError else{
				connectionState = .disconnecting(targetState: .error)
				print("❌ error reading simulated inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulatorInputs += 1
		}
	}
	
	override func writeOutputModules() {
		addressPageSimulatorOutputs = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulatorOutputs*addressPageLengthPerModule

			let writeResult = modbusModule.writeAllOutputs(connection: modbusConnection, addressPage:pageStart)
			guard writeResult == .noError else{
				connectionState = .disconnecting(targetState: .error)
				print("❌ error writing simulated inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulatorOutputs += 1
		}
	}
	
}


