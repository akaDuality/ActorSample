import XCTest
@testable import ActorSample

final class ActorSampleTests: XCTestCase {
    
    func test_main() {
        let sut = PaymentMethodService_JustMain()
        
        sut.prefetch(unitId: 1)
        
        _ = sut.paymentMethods.first
    }
    
    func test_oneUser() {
        let sut = PaymentMethodService_Background()
        
        sut.prefetch(unitId: 1)
        
        _ = sut.paymentMethods.first
    }
    
    let users_count = 10_000
    
    func test_realApp() {
        let sut = PaymentMethodService_Background()
        
        for i in 0...users_count {
            sut.prefetch(unitId: i)
            
            _ = sut.paymentMethods.first
        }
    }
    
    func test_barier() {
        let sut = PaymentMethodService_Barier()
        
        for i in 0...users_count {
            sut.prefetch(unitId: i)
            
            _ = sut.paymentMethods.first
        }
    }
    
    func test_actor() async {
        let sut = PaymentMethodActor()
        let concurrentQueue = DispatchQueue.global(qos: .background)
        
        for i in 0...users_count {
            concurrentQueue.async {
                Task {
                    await sut.prefetch(unitId: i)
                }
            }

            _ = await sut.paymentMethods.first
        }
    }
}
