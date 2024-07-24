import Foundation

open class IOModule {
	
	public let rackNumber: Int
	public let slotNumber: Int
	public var channels: [IOSignal]
	public var status: IOError
	
	public let analogInRanges: [ClosedRange<Int>]
	public let analogOutRanges: [ClosedRange<Int>]
	public let digitalInRanges: [ClosedRange<Int>]
	public let digitalOutRanges: [ClosedRange<Int>]
	
	public init(rackNumber: Int = 0, slotNumber: Int = 0, channels: [IOSignal], status: IOError = .noError) {
		self.rackNumber = rackNumber
		self.slotNumber = slotNumber
		self.channels = channels
		self.status = status
		
		// Compute the ranges once during initialization
		self.analogInRanges = IOModule.consecutiveRanges(signals: channels.filter { $0.ioType == .analogIn })
		self.analogOutRanges = IOModule.consecutiveRanges(signals: channels.filter { $0.ioType == .analogOut })
		self.digitalInRanges = IOModule.consecutiveRanges(signals: channels.filter { $0.ioType == .digitalIn })
		self.digitalOutRanges = IOModule.consecutiveRanges(signals: channels.filter { $0.ioType == .digitalOut })
	}
	
	private static func consecutiveRanges(signals: [IOSignal]) -> [ClosedRange<Int>] {
		let sortedSignals = signals.sorted(by: { $0.number < $1.number })
		var consecutiveRanges: [ClosedRange<Int>] = []
		var lowerBound: Int? = nil
		var upperBound: Int? = nil
		for (index, item) in sortedSignals.enumerated() {
			
			if (index == 0) || (lowerBound == nil) {
				lowerBound = item.number
			}
			if (index == sortedSignals.count - 1) || (sortedSignals[index].number + 1 < sortedSignals[index + 1].number) {
				upperBound = item.number
			}
			if (lowerBound != nil) && (upperBound != nil) {
				consecutiveRanges.append(lowerBound!...upperBound!)
				upperBound = nil
				lowerBound = nil
			}
		}
		return consecutiveRanges
	}
	
}
