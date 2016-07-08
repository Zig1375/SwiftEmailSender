import Foundation

struct SyncronizedDictionary<Key : Hashable, Value> {
    private var array : [Key : Value] = [Key : Value]();
    private let _lock = NSLock();

    subscript(index : Key) -> Value? {
        set {
            _lock.lock();
            self.array[index] = newValue
            _lock.unlock();
        }
        get {
            var element : Value?;

            _lock.lock();
            element = self.array[index];
            _lock.unlock();

            return element;
        }
    }

    var count : Int {
        var element : Int = 0;
        _lock.lock();
        element = self.array.count;
        _lock.unlock();
        return element;
    }

    var values : LazyMapCollection<Dictionary<Key, Value>, Value> {
        var v : LazyMapCollection<Dictionary<Key, Value>, Value>?;

        _lock.lock();
        v = self.array.values;
        _lock.unlock();

        return v!;
    }

    var keys : LazyMapCollection<Dictionary<Key, Value>, Key> {
        var k : LazyMapCollection<Dictionary<Key, Value>, Key>?;

        _lock.lock();
        k = self.array.keys;
        _lock.unlock();

        return k!;
    }

    mutating func remove(key : Key) {
        _lock.lock();
        self.array.removeValue(forKey : key);
        _lock.unlock();
    }

    mutating func removeAll() {
        _lock.lock();
        self.array.removeAll();
        _lock.unlock();
    }

    func get<T>(key : Key) -> T? {
        var res : T?;
        _lock.lock();
        res = array[key] as? T;
        _lock.unlock();

        return res;
    }
}
