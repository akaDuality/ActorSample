import Foundation

struct PaymentMethod: Equatable {
    let id: Int
}

class PaymentMethodService_MainSample {
    func prefetch(unitId: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            /// Что-то делаем
            
            DispatchQueue.main.async {
                self.paymentMethods = [PaymentMethod(id: unitId)]
            }
        }
    }

    var paymentMethods: [PaymentMethod] = []
}

class PaymentMethodService_JustMain {
    func prefetch(unitId: Int) {
        // Called on Main queue
        
        DispatchQueue.main.async {
            self.paymentMethods = [PaymentMethod(id: unitId)]
        }
    }

    var paymentMethods: [PaymentMethod] = []
}

class PaymentMethodService_Background {
    
    let concurrentQueue = DispatchQueue.global(qos: .background)
    
    func prefetch(unitId: Int) {
        concurrentQueue.async {
            self.paymentMethods = [PaymentMethod(id: unitId)]
        }
    }

    var paymentMethods: [PaymentMethod] = []
}

class PaymentMethodService_Barier {
    
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

// https://stackoverflow.com/questions/58236153/dispatchqueue-sync-vs-sync-barrier-in-concurrent-queue




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
