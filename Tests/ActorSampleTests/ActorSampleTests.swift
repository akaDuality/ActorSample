import XCTest
@testable import ActorSample

final class ActorSampleTests: XCTestCase {

    func testPrefetchAndGet() {
        let sut = PaymentMethodService()
        
        sut.prefetch(unitId: "1")
        
        XCTAssertEqual(sut.paymentMethods,
                       [PaymentMethod(name: "ApplePay"),
                        PaymentMethod(name: "SberPay")])
    }
    
    func testPrefetchAndGet_Actor() async {
        let sut = PaymentMethodActor()
        
        await sut.prefetch(unitId: "1")
        
        let methods = await sut.paymentMethods
        XCTAssertEqual(methods,
                       [PaymentMethod(name: "ApplePay"),
                        PaymentMethod(name: "SberPay")])
    }
}

class PaymentMethodService {
    func prefetch(unitId: String) {
        Task {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    self.paymentMethods = [PaymentMethod(name: "ApplePay"),
                                           PaymentMethod(name: "SberPay")]
                    
                    continuation.resume()
                }
            }
        }
    }
    
    var paymentMethods: [PaymentMethod] = []
}

// 1. Allow synchronous access to actor’s members from within itself,
// 2. Allow only asynchronous access to the actor’s members from any asynchronous context, and
// 3. Allow only asynchronous access to the actor’s members from outside the actor.
actor PaymentMethodActor {
    func prefetch(unitId: String) {
        Task {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    Task {
                        self.paymentMethods = [PaymentMethod(name: "ApplePay"),
                                               PaymentMethod(name: "SberPay")]
                        continuation.resume()
                    }
                }
            }
        }
    }

    var paymentMethods: [PaymentMethod] = []
}

struct PaymentMethod: Equatable {
    let name: String
}
