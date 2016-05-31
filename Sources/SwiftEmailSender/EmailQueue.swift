import Foundation

public class EmailQueue {
    static let VERSION = "0.0.1";

    private var hosts = SyncronizedDictionary<String, EmailHost>();

    public init() {

    }

    public func addHost(alias : String, host : String, port : UInt32, username : String, password : String, from : String, headers : [String]? = nil, interval : UInt32 = 60) {
        let eHost = EmailHost(host : host, port : port, username: username, password: password, from: from, headers : headers, interval : interval);
        self.hosts[alias] = eHost;
    }

    public func addHost(alias : String, host : String, username : String, password : String, from : String, headers : [String]? = nil, interval : UInt32 = 60) {
        self.addHost(alias : alias, host : host, port : 25, username: username, password: password, from : from, headers : headers, interval : interval);
    }

    public func addEmail(alias : String, email : Email) -> Bool {
        if (!email.validate()) {
            print("EmailQueue\tInvalid email.");
            return false;
        }

        if let host = self.hosts[alias] {
            host.add(email : email);
            return true;
        }

        return false;
    }
}
