//
//  ModbusSimulator.swift
//
//
//  Created by Jan Verrept on 28/11/2019.
//

import ClibModbus
import Foundation
import JVCocoa
import OSLog

open class ModbusSimulator: ModbusDriver{
    
    private let addressPageLengthPerModule = 100
    
    public override init(ipAddress:String = "127.0.0.1", port:Int = 502){
		
		#if DEBUG
		AppController(name: "ModbusServerPro").startIfInstalled()
		#endif
		
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
        let logger = Logger(subsystem: "be.oneclick.ModbusDriver", category: "Simulated Inputs")
        logger.log("🥽\tReading simulated inputs @\(self.ipAddress, privacy:.public)")

		var addressPageSimulator = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulator*addressPageLengthPerModule
			
			let readResult = modbusModule.readAllInputs(connection: modbusConnection, pageStart:pageStart)
			guard readResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(readResult))
                logger.error("Error reading simulated inputs @\(self.ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulator += 1
		}
	}
	
	func readSimulatorOutputs() {
		// Traverse all modules within this driver,
		// (because of possible mixed signal-types within as single module)
        let logger = Logger(subsystem: "be.oneclick.ModbusDriver", category: "Simulated Outputs")
        logger.log("🥽\tReading simulated outputs @\(self.ipAddress, privacy:.public)")

		var addressPageSimulator = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulator*addressPageLengthPerModule
			
			let readResult = modbusModule.readAllOutputs(connection: modbusConnection, pageStart:pageStart)
			guard readResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(readResult))
                logger.error("Error reading simulated outputs @\(self.ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulator += 1
		}
	}
	
	func writeSimulatorOutputs() {
		// Traverse all modules within this driver,
		// (because of possible mixed signal-types within as single module)
        let logger = Logger(subsystem: "be.oneclick.ModbusDriver", category: "Simulated Outputs")
        logger.log("✏️\tWriting simulated outputs @\(self.ipAddress, privacy:.public)")

		var addressPageSimulator = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulator*addressPageLengthPerModule
			
			let writeResult = modbusModule.writeAllOutputs(connection: modbusConnection, addressPage:pageStart)
			guard writeResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(writeResult))
                logger.error("Error writing simulated outputs @\(self.ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulator += 1
		}
	}
	
}


