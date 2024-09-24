//
//  IODriver.swift
//
//
//  Created by Jan Verrept on 11/02/2021.
//

import Foundation
import JVSwiftCore

// Define PLC-types
public protocol IODriver:AnyObject{
	
	var ioModules:[IOModule] {get set}
	var ioFailure:Bool {get set}
	
	func readAllInputs() async throws
	func writeAllOutputs() async throws
	
}

public typealias IOSimulator = IODriver
