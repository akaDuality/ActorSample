import XCTest
@testable import ActorSample

final class ActorSampleTests: XCTestCase {

    func testPrefetchAndGet() {
        let sut = PaymentMethodService()
        
        let count = 10_000
        
        for i in 0...count {
            DispatchQueue.global(qos: .userInitiated).async {
                sut.prefetch(unitId: i)
            }
            DispatchQueue.main.async {
                _ = sut.paymentMethods.first
            }
        }
    }
}

class PaymentMethodService {
    
    let serialQueue = DispatchQueue(label: "Payment")
    
    func prefetch(unitId: Int) {
        serialQueue.async {
            self._paymentMethods = [PaymentMethod(id: unitId)]
        }
    }
    
    
    private var _paymentMethods: [PaymentMethod] = []
    var paymentMethods: [PaymentMethod] {
        serialQueue.sync(flags: .barrier, execute: {
            return _paymentMethods
        })
    }
}

struct PaymentMethod: Equatable {
    let id: Int
}

// https://stackoverflow.com/questions/58236153/dispatchqueue-sync-vs-sync-barrier-in-concurrent-queue
