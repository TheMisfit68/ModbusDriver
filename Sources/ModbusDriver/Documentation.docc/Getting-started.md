# Getting started
@Metadata {
	@PageKind(sampleCode)
	@PageColor(green)
}

Create a small project with some digital inputs and digital outputs.

## Overview
This sample gets you connected to a digital input module and a digital output module that are part of to the same ModbusServer, and then reads the inputs and writes the outputs.
 

## Essentials

### Define a hardwareconfiguration

Upon intitalization each ``ModbusModule`` has a rack number, a slot number to define it's physical location.  
Each ``ModbusModule`` also has an array of ``ModbusSignal``s associated with it.  
Together these properties are what is known as the _Hardwareconfiguration_ and
wil define the destination addresses for the ``ModbusModule`` and each of it's individual ``ModbusSignal``s.

> important: The Modbus protocol uses 0-based addressing, so the first rack is rack 0, the first slot of a rack is slot 0 and the first IOChannel of any IOModule is channel 0.

> Note:Depending on the ``ModbusSignal``s type the Modbus protocol defines standard address ranges to read from or write to:

The standard Modbus addressing scheme:

| Location  | Table Name   | Size  | Type  |
| ------------ | ------------------ |  ------------ | ------------ | 
| 00001 - 09999 | Discrete Inputs  | 1 bit | Read-only | 
| 10001 - 19999  | Coils | 1 bit | Read-write | 
| 30001 - 39999 | Input Registers | 16 bit word | Read-only | 
| 40001 - 49999 | Holding Registers | 16 bit word | Read-write | 

Lets define a _hardwareconfiguration_ containing a 4 channel digital input module and a 4 channel digital output module in the first 2 slots of the very first rack of ``ModbusModule``s.


```swift

let myDigitalInputModule = IOModule(rack:0, slot:0,
	signals: [
	DigitalInputSignal(channelNumber:0),
	DigitalInputSignal(channelNumber:1),
	DigitalInputSignal(channelNumber:2),
	DigitalInputSignal(channelNumber:3)
	]
)
let myDigitalOutputModule = IOModule(rack:0, slot:1,
	signals: [
	DigitalOutputSignal(channelNumber:0),
	DigitalOutputSignal(channelNumber:1),
	DigitalOutputSignal(channelNumber:2),
	DigitalOutputSignal(channelNumber:3)
	]
)
```

### Connect to the Modbus server

Add your hardwareconfiguration to a ModbusDriver that will thet automatically connect to your Modbus server:

> Note:The standard port for Modbus TCP is 502

```swift
let modbusDriver = ModbusDriver(IPAddress: "192.168.0.100", port: 502)
modbusDriver.modbusModules = [
	myDigitalInputModule, 
	myDigitalOutputModule
]
```

### Start polling the Modbus server and read/write some ModbusSignals

```swift
modbusDriver.readAllInputs()
let theFirstInputValue:Bool? = myDigitalInputModule.signals[0].logicalValue

let theFirstOutputValue:Bool = true
myDigitalOutputModule.signals[0].logicalValue = theFirstOutputValue
modbusDriver.writeAllOutputs()

```

that's it! 

> tip: If you don't have a some Modbus hardware handy, read on to the next section to learn how to use a ``ModbusSimulator`` instead.
