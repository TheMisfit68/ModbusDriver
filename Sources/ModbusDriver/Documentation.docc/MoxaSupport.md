# Built in support for Moxa IOLogic 1200 series modules
@Metadata {
	@PageKind(sampleCode)
	@PageColor(green)
}

This framework has native support for some ``IOLogikE1200Series`` modules from the Moxa-brand.

## Overview

The Moxa ``IOLogikE1200Series`` modules are a series of IO-modules that can be daisy-chained using ethernet, connected to a network and controlled using the Modbus-over-ethernet protocol.

![A Moxa brand IO Module](MoxaIOLogicModule.png)

## Supported Module-types
| Moxa module type  | Description   |
| ------------ | ------------------ | 
| ``IOLogicE1240`` | 8  analog inputs  |
| ``IOLogicE1241`` | 4  analog outputs |
| ``IOLogicE1210`` | 16 digital inputs |
| ``IOLogicE1211`` | 16 digital outputs|

## Sample
> Note: Each of the Moxa modules has it's own IP-address but there are no racknumbers, slotnumbers or custom IOSignals to deal with, hence creating an instance of a Moxa module becomes very simple.

```swift
let analogInput = IOLogicE1240(ipAddress: "192.168.0.100")
let analogOutput = IOLogicE1241(ipAddress: "192.168.0.101")
let digitalInput = IOLogicE1210(ipAddress: "192.168.0.102")
let digitalOutput = IOLogicE1211(ipAddress: "192.168.0.103")


// You can start polling and 
// processing the IOSignals for each module

```


