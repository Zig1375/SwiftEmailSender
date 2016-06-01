import Foundation
import Dispatch

struct SyncronizedDictionary<Key : Hashable, Value> {
    private var array : [Key : Value] = [Key : Value]();
    private let accessQueue = dispatch_queue_create("SynchronizedDictionaryAccess", DISPATCH_QUEUE_SERIAL)!;

    subscript(index : Key) -> Value? {
        set {
            dispatch_sync(self.accessQueue) {
                self.array[index] = newValue
            }
        }
        get {
            var element : Value?;

            dispatch_sync(self.accessQueue) {
                element = self.array[index];
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

    var values : LazyMapCollection<Dictionary<Key, Value>, Value> {
        var v : LazyMapCollection<Dictionary<Key, Value>, Value>?;
        dispatch_sync(self.accessQueue) {
            v = self.array.values;
        }

        return v!;
    }

    var keys : LazyMapCollection<Dictionary<Key, Value>, Key> {
        var k : LazyMapCollection<Dictionary<Key, Value>, Key>?;
        dispatch_sync(self.accessQueue) {
            k = self.array.keys;
        }

        return k!;
    }

    mutating func remove(key : Key) {
        dispatch_sync(self.accessQueue) {
            self.array.removeValue(forKey : key);
        }
    }

    mutating func removeAll() {
        dispatch_sync(self.accessQueue) {
            self.array.removeAll();
        }
    }

    func get<T>(key : Key) -> T? {
        return array[key] as? T;
    }
}
