import Foundation

struct SyncronizedArray<Value> {
    private var array : [Value] = [Value]();
    private let _lock = NSLock();

    subscript(index : Int) -> Value? {
        get {
            var element : Value?;

            _lock.lock();

            if (self.array.count > index) {
                element = self.array[index];
            }

            _lock.unlock();

            return element;
        }
    }

    var count : Int {
        defer {
            _lock.unlock();
        }

        _lock.lock();
        return self.array.count;
    }

    mutating func append(_ value : Value) {
        _lock.lock();
        self.array.append(value);
        _lock.unlock();
    }

    mutating func remove(_ index : Int) -> Value? {
        var element : Value?;

        _lock.lock();

        if (self.array.count > index) {
            element = self.array.remove(at : index);
        }

        _lock.unlock();

        return element;
    }
}
