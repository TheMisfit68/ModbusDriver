//
//  IOModule.swift
//  
//
//  Created by Jan Verrept on 11/02/2021.
//

import Foundation

open class IOModule{
	
	public let rackNumber:Int
	public let slotNumber:Int
	public var channels: [IOSignal]
	public var status:IOError = .noError
	
	public var analogInRanges:[ClosedRange<Int>] = []
	public var analogOutRanges:[ClosedRange<Int>] = []
	public var digitalInRanges:[ClosedRange<Int>] = []
	public var digitalOutRanges:[ClosedRange<Int>] = []
	
	public init(racknumber:Int = 0, slotNumber:Int = 0, channels:[IOSignal]){
		
		self.rackNumber = racknumber
		self.slotNumber = slotNumber
		self.channels = channels
		
		// Store consecutive ranges for different type channels, for optimum access later
		self.analogInRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .analogIn})
		self.analogOutRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .analogOut})
		self.digitalInRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .digitalIn})
		self.digitalOutRanges = consecutiveRanges(signals: channels.filter {$0.ioType == .digitalOut})
		
	}
	
	private func consecutiveRanges(signals:[IOSignal])->[ClosedRange<Int>]{
		let sortedSignals = signals.sorted(by: { $0.number < $1.number })
		var consecutiveRanges:[ClosedRange<Int>] = []
		var lowerBound:Int? = nil
		var upperBound:Int? = nil
		for (index, item) in sortedSignals.enumerated(){
			
			if (index == 0) || (lowerBound == nil){
				lowerBound = item.number
			}
			if (index == sortedSignals.count-1) || (sortedSignals[index].number+1 < sortedSignals[index+1].number){
				upperBound = item.number
			}
			if (lowerBound != nil) && (upperBound != nil){
				consecutiveRanges.append(lowerBound!...upperBound!)
				upperBound = nil
				lowerBound =  nil
				
			}
		}
		return consecutiveRanges
	}
}
