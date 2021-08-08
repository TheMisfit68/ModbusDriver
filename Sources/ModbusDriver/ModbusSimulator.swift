//
//  ModbusSimulator.swift
//
//
//  Created by Jan Verrept on 28/11/2019.
//

import ClibModbus
import Foundation
import JVCocoa

open class ModbusSimulator: ModbusDriver{
    
    private let addressPageLengthPerModule = 100
    
    public override init(ipAddress:String = "127.0.0.1", port:Int = 502){
		
		let modbusServerController = AppController(name: "ModbusServerPro")
		if modbusServerController.isInstalled{
			modbusServerController.start()
		}
		
        super.init(ipAddress:ipAddress, port:port)
    }
	
	public override func readAllInputs(){
		parseConnectionState()
		if connectionState == .connected{
			readSimulatorInputs()
			readSimulatorOutputs()
		}
	}
	
	public override func writeAllOutputs(){
		parseConnectionState()
		if connectionState == .connected{
			writeSimulatorOutputs()
		}
	}
    
	func readSimulatorInputs() {
		// Traverse all modules within this driver,
		// (because of possible mixed signal-types within as single module)
		
		print("✅ Simulating inputs @\(ipAddress)")
		var addressPageSimulator = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulator*addressPageLengthPerModule
			
			let readResult = modbusModule.readAllInputs(connection: modbusConnection, pageStart:pageStart)
			guard readResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(readResult))
				print("❌ error reading simulated inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulator += 1
		}
	}
	
	func readSimulatorOutputs() {
		// Traverse all modules within this driver,
		// (because of possible mixed signal-types within as single module)
		
		print("✅ Simulating feedbacks @\(ipAddress)")
		var addressPageSimulator = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulator*addressPageLengthPerModule
			
			let readResult = modbusModule.readAllOutputs(connection: modbusConnection, pageStart:pageStart)
			guard readResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(readResult))
				print("❌ error reading simulated inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulator += 1
		}
	}
	
	func writeSimulatorOutputs() {
		// Traverse all modules within this driver,
		// (because of possible mixed signal-types within as single module)

		print("✅ Simulating outputs @\(ipAddress)")
		var addressPageSimulator = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulator*addressPageLengthPerModule
			
			let writeResult = modbusModule.writeAllOutputs(connection: modbusConnection, addressPage:pageStart)
			guard writeResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(writeResult))
				print("❌ error writing simulated inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulator += 1
		}
	}
	
}


