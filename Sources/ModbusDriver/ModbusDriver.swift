//
//  ModbusDriver.swift
//
//
//  Created by Jan Verrept on 28/11/2019.
//

import ClibModbus
import Foundation

open class ModbusDriver{
	
	indirect enum ConnectionState{
		case disconnecting(targetState:ConnectionState?)
		case disconnected
		case connecting
		case connected
		case error
	}
	
	let ipAddress:String
	let portNumber:Int
	var modbusConnection:OpaquePointer! = nil
	var connectionState:ConnectionState = .disconnected
	
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
		disConnect(targetState: nil)
	}
	
	func connect(){
		modbusConnection = modbus_new_tcp(self.ipAddress, Int32(self.portNumber))
		if modbus_connect(modbusConnection) != -1 {
			connectionState = .connected
			DispatchQueue.main.asyncAfter(deadline: .now() + connectionTTL) {
				// Refresh then connection
				self.connectionState = .disconnecting(targetState: .connecting)
			}
		}else{
			connectionState = .disconnecting(targetState: .error)
		}
	}
	
	func disConnect(targetState:ConnectionState?){
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
		
		switch connectionState{
			case let .disconnecting(targetState):
				print("❌ disconnecting @\(ipAddress)")
				disConnect(targetState: targetState)
			case .disconnected:
				break
			case .connecting:
				print("⛓ connecting @\(ipAddress)")
				connect()
			case .connected:
				print("✅ reading inputs @\(ipAddress)")
				errorCount = 0
				readInputModules()
			case .error:
				errorCount += 1
				if errorCount < maxErrorCount{
					connectionState = .connecting
				}else if errorCount == maxErrorCount{
					DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
						// Try to reconnect after a while
						self.connectionState = .connecting
					}
				}
				
		}
		
	}
	
	public func writeAllOutputs(){
		
		switch connectionState{
			case let .disconnecting(targetState):
				print("❌ disconnecting @\(ipAddress)")
				disConnect(targetState: targetState)
			case .disconnected:
				break
			case .connecting:
				print("⛓ connecting @\(ipAddress)")
				connect()
			case .connected:
				print("✅ writing outputs @\(ipAddress)")
				writeOutputModules()
			case .error:
				errorCount += 1
				if errorCount < maxErrorCount{
					connectionState = .connecting
				}else if errorCount == maxErrorCount{
					DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
						// Try to reconnect after a while
						self.connectionState = .connecting
					}
				}
				
		}
	}
	
	func readInputModules() {
		for modbusModule in modbusModules{
			let readResult = modbusModule.readAllInputs(connection: modbusConnection)
			guard readResult == .noError else{
				connectionState = .disconnecting(targetState: .error)
				print("❌ error reading inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
		}
	}
	
	func writeOutputModules() {
		for modbusModule in modbusModules{
			let writeResult = modbusModule.writeAllOutputs(connection: modbusConnection)
			guard writeResult == .noError else{
				connectionState = .disconnecting(targetState: .error)
				print("❌ error writing inputs @\(ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
		}
	}
	
}


