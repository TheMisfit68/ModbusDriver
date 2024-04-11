# ``ModbusDriver``
@Metadata {
    @PageKind(article)
    @PageColor(green)
}

A driver for the Modbus-over-ethernet-protocol (written in Swift).

## Overview

### Includes native support for IOLogic-modules from the Moxa-brand:
![A Moxa brand Module](MoxaIOLogicModule.png)

| Moxa module type  | Description   |
| ------------ | ------------------ | 
| ``IOLogicE1240`` | 8  analog inputs  |
| ``IOLogicE1241`` | 4  analog outputs |
| ``IOLogicE1210`` | 16 digital inputs |
| ``IOLogicE1211`` | 16 digital outputs|

### Modbus addressing scheme:

| Location  | Table Name   | Size  | Type  |
| ------------ | ------------------ |  ------------ | ------------ | 
| 00001 - 09999 | Discrete Inputs  | 1 bit | Read-only | 
| 10001 - 19999  | Coils | 1 bit | Read-write | 
| 30001 - 39999 | Input Registers | 16 bit word | Read-only | 
| 40001 - 49999 | Holding Registers | 16 bit word | Read-write | 


## Topics

### Essentials
