import XCTest
@testable import ActorSample

final class ActorSampleTests: XCTestCase {

    func testPrefetchAndGet() {
        let sut = PaymentMethodService()
        
        for i in 0..<10000 {
            DispatchQueue.global(qos: .userInitiated).async {
                sut.prefetch(unitId: i)
            }
            DispatchQueue.main.async {
                _ = sut.paymentMethods
            }
        }
    }
}

class PaymentMethodService {
    func prefetch(unitId: Int) {
        self.paymentMethods = [PaymentMethod(id: unitId)]
    }
    
    var paymentMethods: [PaymentMethod] = []
}

struct PaymentMethod: Equatable {
    let id: Int
}
