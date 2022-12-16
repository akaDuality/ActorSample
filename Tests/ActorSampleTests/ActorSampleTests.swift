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
    
    func testPrefetchAndGetActor() {
        let sut = PaymentMethodActor()
        
        let count = 10_000
        
        for i in 0...count {
            DispatchQueue.global(qos: .userInitiated).async {
                Task {
                    await sut.prefetch(unitId: i)
                }
            }
            DispatchQueue.main.async {
                Task {
                    _ = await sut.paymentMethods.first
                }
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




/// https://trycombine.com/posts/swift-actors/
/// 1. Allow synchronous access to actor’s members from within itself,
/// 2. Allow only asynchronous access to the actor’s members from any asynchronous context, and
/// 3. Allow only asynchronous access to the actor’s members from outside the actor.
///
/// This way the actor itself accesses its data synchronously,
/// but any other code from outside is required asynchronous access
/// (with implicit synchronization) to prevent data races.

actor PaymentMethodActor {
    func prefetch(unitId: Int) {
        self.paymentMethods = [PaymentMethod(id: unitId)]
    }
    
    var paymentMethods: [PaymentMethod] = []
}





struct PaymentMethod: Equatable {
    let id: Int
}

// https://stackoverflow.com/questions/58236153/dispatchqueue-sync-vs-sync-barrier-in-concurrent-queue
