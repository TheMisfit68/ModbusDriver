//
//  ModbusDriver.swift
//
//
//  Created by Jan Verrept on 28/11/2019.
//

import ClibModbus
import Foundation

open class ModbusDriver{
	
	let ipAddress:String
	let portNumber:Int
	var modbusConnection:OpaquePointer! = nil
	
	indirect enum ConnectionState:Equatable{
		case disconnectingWith(targetState:ConnectionState?)
		case disconnected
		case connecting
		case connected
		case error(ModbusError)
	}
	
	var connectionState:ConnectionState = .disconnected
	var updatedConnectionState:ConnectionState{
		
		switch connectionState{
			case let .disconnectingWith(targetState):
				print("❌ disconnecting @\(ipAddress)")
				disConnectWith(targetState: targetState)
			case .disconnected:
				break
			case .connecting:
				print("⛓ connecting @\(ipAddress)")
				connect()
			case .connected:
				errorCount = 0
			case .error:
				errorCount += 1
				if errorCount <= maxErrorCount{
					connectionState = .connecting
				}else if errorCount == (maxErrorCount+1){
					DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
						// Try to reconnect after a while
						self.errorCount = 0
						self.connectionState = .connecting
					}
				}
		}
		return connectionState
	}
	
	
	let connectionTTL:TimeInterval = 15.0
	var errorCount:Int = 0
	let maxErrorCount:Int = 5
	let reconnectInterval:TimeInterval = 60.0
	
	public var modbusModules:[ModbusModule] = []
	
	public init(ipAddress:String, port:Int = 502){
		self.ipAddress = ipAddress
		self.portNumber = port
		self.connectionState = .connecting
	}
	
	deinit {
		disConnectWith(targetState: nil)
	}
	
	func connect(){
		modbusConnection = modbus_new_tcp(self.ipAddress, Int32(self.portNumber))
		if modbus_connect(modbusConnection) != -1 {
			connectionState = .connected
			DispatchQueue.main.asyncAfter(deadline: .now() + connectionTTL) {
				self.connectionState = .disconnectingWith(targetState: .connecting) // Refresh then connection
			}
		}else{
			connectionState = .disconnectingWith(targetState: .error(.connectionError)) // Timeout and retry
		}
	}
	
	func disConnectWith(targetState:ConnectionState?){
		if let mbConnection = modbusConnection{
			modbus_close(mbConnection)
			modbus_free(mbConnection)
			modbusConnection = nil
		}
		if let targetState = targetState{
			connectionState = targetState
		}else{
			connectionState = .disconnected
		}
	}
	
	public func readAllInputs(){
		if updatedConnectionState == .connected{
			readInputModules()
		}
	}
	
	public func writeAllOutputs(){
		if updatedConnectionState == .connected{
			writeOutputModules()
		}
	}
	
	func readInputModules() {
		print("✅ reading inputs @\(ipAddress)")
		for modbusModule in modbusModules{
			let readResult = modbusModule.readAllInputs(connection: modbusConnection)
			guard readResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(readResult))
				print("❌ error reading inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
		}
	}
	
	func writeOutputModules() {
		print("✅ writing outputs @\(ipAddress)")
		for modbusModule in modbusModules{
			let writeResult = modbusModule.writeAllOutputs(connection: modbusConnection)
			guard writeResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(writeResult))
				print("❌ error writing inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
		}
	}
	
}


