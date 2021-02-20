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
	
	public override func readAllInputs(){
		if updatedConnectionState == .connected{
			simulateInputModules()
		}
	}
	
	public override func writeAllOutputs(){
		if updatedConnectionState == .connected{
			simulateOutputModules()
			simulateFeedbacks() // Updates the IO-feedback-values
		}
	}
    
	func simulateInputModules() {
		print("✅ Simulating inputs @\(ipAddress)")
		addressPageSimulatorInputs = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulatorInputs*addressPageLengthPerModule
			
			let readResult = modbusModule.readAllInputs(connection: modbusConnection, pageStart:pageStart)
			guard readResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(readResult))
				print("❌ error reading simulated inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulatorInputs += 1
		}
	}
	
	func simulateOutputModules() {
		print("✅ Simulating outputs @\(ipAddress)")
		addressPageSimulatorOutputs = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulatorOutputs*addressPageLengthPerModule

			let writeResult = modbusModule.writeAllOutputs(connection: modbusConnection, addressPage:pageStart)
			guard writeResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(writeResult))
				print("❌ error writing simulated inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulatorOutputs += 1
		}
	}
	
	func simulateFeedbacks() {
		print("✅ Simulating feedbacks @\(ipAddress)")
		addressPageSimulatorInputs = 0
		for modbusModule in modbusModules{
			let pageStart = addressPageSimulatorInputs*addressPageLengthPerModule
			
			let readResult = modbusModule.readAllOutputs(connection: modbusConnection, pageStart:pageStart)
			guard readResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(readResult))
				print("❌ error reading simulated inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
			addressPageSimulatorInputs += 1
		}
	}
	
}


