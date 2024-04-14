# Installing libModbus
@Metadata {
	@PageKind(article)
	@PageColor(green)
}

The installation process for the libModbus system library.

## Overview

The ModbusDriver framework is a bridge framework that wraps the [libModbus](https://libmodbus.org/) system library into Swift-friendly APIs.  
> Important:The libModbus system library should be preinstalled on your device before you can use the ``ModbusDriver`` framework in your project.

### Installing the libmodbus system library

#### From the command line
Installation of the system library is typically done using the [Homebrew](https://brew.sh) packagemanager.  
Refer to the  [Homebrew homepage](https://brew.sh) for installation instructions for HomeBrew itself.

Then from the terminal type the following command to install the libmodbus system library:
```bash
brew install libmodbus
```
#### Using a GUI
Alternatively, you can use [Cakebrew](https://www.cakebrew.com) for Mac to install the system library.
 [Cakebrew](https://www.cakebrew.com) is a graphical user interface for Homebrew.

![The main window of the Cakebrew GUI](Cakebrew.png)



