import Foundation
import Dispatch

struct SyncronizedArray<Value> {
    private var array : [Value] = [Value]();
    private let accessQueue = dispatch_queue_create("SynchronizedArrayAccess", DISPATCH_QUEUE_SERIAL);

    subscript(index : Int) -> Value? {
        get {
            var element : Value?;

            dispatch_sync(self.accessQueue) {
                if (self.array.count > index) {
                    element = self.array[index];
                }
            }

            return element;
        }
    }

    var count : Int {
        var element : Int = 0;
        dispatch_sync(self.accessQueue) {
            element = self.array.count;
        }
        return element;
    }

    mutating func append(_ value : Value) {
        dispatch_sync(self.accessQueue) {
            self.array.append(value);
        }
    }

    mutating func remove(_ index : Int) -> Value? {
        var element : Value?;

        dispatch_sync(self.accessQueue) {
            if (self.array.count > index) {
                element = self.array.remove(at : index);
            }
        }

        return element;
    }
}
