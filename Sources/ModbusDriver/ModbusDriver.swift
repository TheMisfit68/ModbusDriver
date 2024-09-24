//
//  ModbusDriver.swift
//
//
//  Created by Jan Verrept on 28/11/2019.
//

import Foundation
import OSLog
import ClibModbus
import JVSwiftCore
import Foundation

/// ModbusDriver is the main class for this framework
/// It will connect to modbus modules and read/write their inputs/outputs
@ModbusActor open class ModbusDriver:Loggable{
	
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
	public func parseConnectionState() async{
		
		switch connectionState{
			case let .disconnectingWith(targetState):
				ModbusDriver.logger.info("❌\tDisconnecting @\(self.ipAddress, privacy: .public)")
				await disConnectWith(targetState: targetState)
			case .disconnected:
				break
			case .connecting:
				ModbusDriver.logger.info("🔗\tConnecting @\(self.ipAddress, privacy: .public)")
				await connect()
			case .connected:
				errorCount = 0
			case .error:
				errorCount += 1
				if errorCount == maxErrorCount{
					try? await Task.sleep(nanoseconds: UInt64(reconnectInterval * 1_000_000_000))
					await reconnect()
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
		Task{ [weak self] in
			await self?.disConnectWith(targetState: nil)
		}
	}
	
	public func connect() async{
		if (self.connectionState != .connected){
			
			modbusConnection = modbus_new_tcp(self.ipAddress, Int32(self.portNumber))
			let connectionResult = modbus_connect(modbusConnection)
			if  connectionResult != -1 {
				connectionState = .connected
				
				try? await Task.sleep(nanoseconds: UInt64(self.connectionTTL * 1_000_000_000))
				
				await self.reconnect(force: true) // Refresh the connection
				
			}else{
				connectionState = .disconnectingWith(targetState: .error(.connectionError)) // Retry a few times and optionaly timeout
			}
		}
	}
	
	func disConnectWith(targetState:ConnectionState?) async{
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
	
	func reconnect(force:Bool = false) async{
		if (force || (self.connectionState != .connected) ) && (self.connectionState != .connecting){
			self.connectionState = .disconnectingWith(targetState: .connecting)
		}
	}
	
	public func readAllInputs() async{
		await parseConnectionState()
		if connectionState == .connected{
			await readInputModules()
			await readOutputModules()
		}
	}
	
	public func writeAllOutputs() async{
		await parseConnectionState()
		if connectionState == .connected{
			await writeOutputModules()
		}
	}
	
	func readInputModules() async {
		ModbusDriver.logger.log("👓\tReading inputs @\(self.ipAddress, privacy: .public)")
		
		for modbusModule in modbusModules { // Assuming modbusModules is now a list of ModbusModule objects
			do {
				// Call the `readAllInputs` method which now uses async/throws pattern
				try await modbusModule.readAllInputs(connection: modbusConnection)
			} catch let error as ModbusError {
				connectionState = .disconnectingWith(targetState: .error(error))
				ModbusDriver.logger.error("Error reading inputs @\(self.ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber): \(error.localizedDescription)")
				break
			} catch {
				connectionState = .disconnectingWith(targetState: .error(.unknownError))
				ModbusDriver.logger.error("Unexpected error reading inputs @\(self.ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
		}
	}
	
	func readOutputModules() async {
		ModbusDriver.logger.log("👓\tReading outputs @\(self.ipAddress, privacy: .public)")
		
		for modbusModule in modbusModules {
			do {
				// Call the `readAllOutputs` method with async/throws pattern
				try await modbusModule.readAllOutputs(connection: modbusConnection)
			} catch let error as ModbusError {
				connectionState = .disconnectingWith(targetState: .error(error))
				ModbusDriver.logger.error("Error reading outputs @\(self.ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber): \(error.localizedDescription)")
				break
			} catch {
				connectionState = .disconnectingWith(targetState: .error(.unknownError))
				ModbusDriver.logger.error("Unexpected error reading outputs @\(self.ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
		}
	}
	
	func writeOutputModules() async {
		ModbusDriver.logger.log("🖌\tWriting outputs @\(self.ipAddress, privacy: .public)")
		
		for modbusModule in modbusModules {
			do {
				// Call the `writeAllOutputs` method with async/throws pattern
				try await modbusModule.writeAllOutputs(connection: modbusConnection)
			} catch let error as ModbusError {
				connectionState = .disconnectingWith(targetState: .error(error))
				ModbusDriver.logger.error("Error writing outputs @\(self.ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber): \(error.localizedDescription)")
				break
			} catch {
				connectionState = .disconnectingWith(targetState: .error(.unknownError))
				ModbusDriver.logger.error("Unexpected error writing outputs @\(self.ipAddress), module \(modbusModule.rackNumber).\(modbusModule.slotNumber)")
				break
			}
		}
	}
	
}


