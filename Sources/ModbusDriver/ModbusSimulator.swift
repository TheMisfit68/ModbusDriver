//
//  ModbusSimulator.swift
//
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import OSLog
import JVSwiftCore
import JVScripting
import ClibModbus

/// ModbusSimulator is just a special type  of ModbusDriver
/// It is used during development to connect to a ModbusServer that is running on your development machine.
open class ModbusSimulator: ModbusDriver{
	
    private let addressPageLengthPerModule = 100
    
    public override init(ipAddress:String = "127.0.0.1", port:Int = 502){
		
		#if DEBUG
		AppController(name: "ModbusServerPro", terminal: TerminalDriver()).startIfInstalled()
		#endif
		
        super.init(ipAddress:ipAddress, port:port)
    }
	
	public override func readAllInputs() async{
		await parseConnectionState()
		if connectionState == .connected{
			await readSimulatorInputs()
			await readSimulatorOutputs()
		}
	}
	
	public override func writeAllOutputs() async{
		await parseConnectionState()
		if connectionState == .connected{
			await writeSimulatorOutputs()
		}
	}
    
	/// Traverse all modules within this driver,
	/// (because of possible mixed signal-types within as single module)
	func readSimulatorInputs() async{
		
		ModbusSimulator.logger.log("🥽\tReading simulated inputs @\(self.ipAddress, privacy:.public)")

		var addressPageSimulator = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulator*addressPageLengthPerModule
			
			let readResult = await modbusModule.readAllInputs(connection: modbusConnection, pageStart:pageStart)
			guard readResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(readResult))
				ModbusSimulator.logger.error("Error reading simulated inputs @\(self.ipAddress), module \(modbusModule.modbusModule.rackNumber).\(modbusModule.modbusModule.slotNumber)")
				break
			}
			addressPageSimulator += 1
		}
	}
	
	/// Traverse all modules withiModbusModule this driver,
	/// (because of possible mixed signal-types within as single module)
	func readSimulatorOutputs() async{
		
		ModbusSimulator.logger.log("🥽\tReading simulated outputs @\(self.ipAddress, privacy:.public)")

		var addressPageSimulator = 0
		for modbusActor in modbusModules{
			let pageStart = addressPageSimulator*addressPageLengthPerModule
			
			let readResult = await modbusActor.readAllOutputs(connection: modbusConnection, pageStart:pageStart)
			guard readResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(readResult))
				ModbusSimulator.logger.error("Error reading simulated outputs @\(self.ipAddress), module \(modbusActor.modbusModule.rackNumber).\(modbusActor.modbusModule.slotNumber)")
				break
			}
			addressPageSimulator += 1
		}
	}
	
	/// Traverse all modules within this driver
	func writeSimulatorOutputs() async{
		
		ModbusSimulator.logger.log("✏️\tWriting simulated outputs @\(self.ipAddress, privacy:.public)")

		var addressPageSimulator = 0
		for modbusActor in modbusModules{
			let pageStart = addressPageSimulator*addressPageLengthPerModule
			
			let writeResult = await modbusActor.writeAllOutputs(connection: modbusConnection, addressPage:pageStart)
			guard writeResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(writeResult))
				ModbusSimulator.logger.error("Error writing simulated outputs @\(self.ipAddress), module \(modbusActor.modbusModule.rackNumber).\(modbusActor.modbusModule.slotNumber)")
				break
			}
			addressPageSimulator += 1
		}
	}
	
}


