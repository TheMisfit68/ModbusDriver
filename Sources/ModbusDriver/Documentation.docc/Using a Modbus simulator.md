# Using a Modbus simulator for testing purposes.
@Metadata {
	@PageKind(article)
	@PageColor(green)
}

Test the driver without actual Modbus hardware.

## Overview

For testing purposes, you can use a Modbus simulator to simulate a Modbus device, without the need for any actual Modbus hardware.
There is a [Modbus simulator for MacOS available from the AppStore called ModbusServerPro](https://itunes.apple.com/us/app/modbus-server-pro/id618058292?mt=8).


![The main window of ModbusServerPro application](ModbusServerPro.png)

When you downloaded the Modbus simulator from the AppStore, 
run it on a machine in your local network or simply from your development machine itself, you can use an instance of ``ModbusSimulator`` class from the ModbusDriver framework to connect to it from code automatically.


```swift
let mySimulatedInputModule = IOModule(rack:0, slot:0,
signals: [
		DigitalInputSignal(channelNumber:0),
		DigitalInputSignal(channelNumber:1),
		DigitalInputSignal(channelNumber:2),
		DigitalInputSignal(channelNumber:3)
		]
)
let mySimulatedOutputModule = IOModule(rack:0, slot:1,
signals: [
		DigitalOutputSignal(channelNumber:0),
		DigitalOutputSignal(channelNumber:1),
		DigitalOutputSignal(channelNumber:2),
		DigitalOutputSignal(channelNumber:3)
		]
)

// Connect a ModbusSimulator to simulated hardware running on your development machine.
let modbusSimulator = ModbusSimulator()
modbusSimulator.modbusModules = [
mySimulatedInputModule, 
mySimulatedOutputModule
]

// Start polling the Modbus server and read/write some ModbusSignals
modbusSimulator.readAllInputs()
let theFirstInputValue:Bool? = mySimulatedInputModule.signals[0].logicalValue

let theFirstOutputValue:Bool = true
mySimulatedOutputModule.signals[0].logicalValue = theFirstOutputValue
modbusSimulator.writeAllOutputs()

```

As you can see a ``ModbusSimulator`` is just another type of ``ModbusDriver``.
However it defaults to an IP address of `127.0.0.1` and the logging is slightly different from that of a real ModbusDriver to make it easier to distinguish between the two. 
