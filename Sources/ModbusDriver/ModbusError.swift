//
//  ModbusError.swift
//  
//
//  Created by Jan Verrept on 30/12/2020.
//

import Foundation

public enum ModbusError:Error{
    case connectionError
    case readError
    case writeError
	case unknownError
}
