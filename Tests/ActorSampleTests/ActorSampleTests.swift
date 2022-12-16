import XCTest
@testable import ActorSample

final class ActorSampleTests: XCTestCase {

    func testPrefetchAndGet() {
        let sut = PaymentMethodService()
        
        for i in 0..<1000 {
            DispatchQueue.global(qos: .userInitiated).async {
                sut.prefetch(unitId: "1")
            }
            DispatchQueue.main.async {
                _ = sut.paymentMethods
            }
        }
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
        self.paymentMethods = [PaymentMethod(name: "ApplePay"),
                               PaymentMethod(name: "SberPay")]
    }
    
    var paymentMethods: [PaymentMethod] = []
}

// 1. Allow synchronous access to actor’s members from within itself,
// 2. Allow only asynchronous access to the actor’s members from any asynchronous context, and
// 3. Allow only asynchronous access to the actor’s members from outside the actor.
actor PaymentMethodActor {
    func prefetch(unitId: String) {
        self.paymentMethods = [PaymentMethod(name: "ApplePay"),
                               PaymentMethod(name: "SberPay")]
        
    }

    var paymentMethods: [PaymentMethod] = []
}

struct PaymentMethod: Equatable {
    let name: String
}
