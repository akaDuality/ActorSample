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


//actor PaymentMethodActor {
//    func prefetch(unitId: String) {
//        DispatchQueue.main.async {
//            self.paymentMethods = [PaymentMethod(name: "ApplePay"),
//                                   PaymentMethod(name: "SberPay")]
//        }
//
//    }
//
//    var paymentMethods: [PaymentMethod] = []
//}

struct PaymentMethod: Equatable {
    let name: String
}
