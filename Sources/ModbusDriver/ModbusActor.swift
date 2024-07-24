//
//  ModbusActor.swift
//  
//
//  Created by Jan Verrept on 21/07/2024.
//

import Foundation

@globalActor public actor ModbusActor: GlobalActor {
	public static let shared = ModbusActor()
}


@ModbusActor public class ModbusModuleActor {
	
	public let modbusModule: ModbusModule
	
	public init(rackNumber: Int = 0, slotNumber: Int = 0, channels: [ModbusSignal], addressOffset: Int = 0) {
		self.modbusModule = ModbusModule(racknumber: rackNumber, slotNumber: slotNumber, channels: channels, addressOffset: addressOffset)
	}
	
	public func readAllInputs(connection modbus: OpaquePointer, pageStart: Int = 0) async -> ModbusError {
		return  modbusModule.readAllInputs(connection: modbus, pageStart: pageStart)
	}
	
	public func readAllOutputs(connection modbus: OpaquePointer, pageStart: Int = 0) async -> ModbusError {
		return modbusModule.readAllOutputs(connection: modbus, pageStart: pageStart)
	}
	
	public func writeAllOutputs(connection modbus: OpaquePointer, addressPage: Int = 0) async -> ModbusError {
		return modbusModule.writeAllOutputs(connection: modbus, addressPage: addressPage)
	}
}

