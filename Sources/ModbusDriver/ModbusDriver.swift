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
	
	public indirect enum ConnectionState:Equatable{
		case disconnectingWith(targetState:ConnectionState?)
		case disconnected
		case connecting
		case connected
		case error(ModbusError)
	}
	
	public var connectionState:ConnectionState = .disconnected
	public func parseConnectionState(){
				
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
				if errorCount <= maxErrorCount{
					errorCount += 1
					reconnect()
				}else if errorCount == (maxErrorCount+1){
					DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
						// Try to reconnect after a while
						self.errorCount = 0
						self.reconnect()
					}
				}
		}
	}
	
	let connectionTTL:TimeInterval = 15.0
	public var errorCount:Int = 0
	public let maxErrorCount:Int = 5
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
	
	public func connect(){
		if (self.connectionState != .connected){
			
			modbusConnection = modbus_new_tcp(self.ipAddress, Int32(self.portNumber))
			let connectionResult = modbus_connect(modbusConnection)
			if  connectionResult != -1 {
				connectionState = .connected
				DispatchQueue.main.asyncAfter(deadline: .now() + connectionTTL) {
					self.reconnect(force: true) // Refresh the connection
				}
			}else{
				connectionState = .disconnectingWith(targetState: .error(.connectionError)) // Retry a few times and optionaly timeout
			}
		}
	}
	
	func disConnectWith(targetState:ConnectionState?){
		if let mbConnection = modbusConnection{
			modbus_close(mbConnection)
			modbus_free(mbConnection)
			modbusConnection = nil
		}
		connectionState = .disconnected
		if let targetState = targetState{
			connectionState = targetState
		}
	}
	
	func reconnect(force:Bool = false){
		if (force || (self.connectionState != .connected) ) && (self.connectionState != .connecting){
			self.connectionState = .disconnectingWith(targetState: .connecting)
		}
	}
	
	public func readAllInputs(){
		parseConnectionState()
		if connectionState == .connected{
			readInputModules()
		}
	}
	
	public func writeAllOutputs(){		
		parseConnectionState()
		if connectionState == .connected{
			readOutputModules() // Updates the IO-feedback-values
			writeOutputModules()
		}
	}
	
	func readInputModules() {
		// Traverse all modules within this driver,
		// (because of possible mixed signal-types within as single module)
		
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
	
	func readOutputModules() {
		// Traverse all modules within this driver,
		// (because of possible mixed signal-types within as single module)
		
		print("✅ reading outputs @\(ipAddress)")
		for modbusModule in modbusModules{
			let readResult = modbusModule.readAllOutputs(connection: modbusConnection)
			guard readResult == .noError else{
				connectionState = .disconnectingWith(targetState: .error(readResult))
				print("❌ error reading outputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
		}
	}
	
	func writeOutputModules() {
		// Traverse all modules within this driver,
		// (because of possible mixed signal-types within as single module)
		
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


