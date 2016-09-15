import Foundation
import EmailCurl

class EmailHost {
    private var sentCounter : UInt32 = 0;
    private let _lock = NSLock();

    let host : String;
    let port : UInt32;
    let username : String;
    let password : String;
    let from     : String;
    let headers  : [String]?;
    let interval : UInt32;
    let maxSentInInterval : UInt32 = 5;

    var queue = SyncronizedArray<Email>();

    init(host : String, port : UInt32, username : String, password : String, from : String, headers : [String]? = nil, interval : UInt32 = 60) {
        self.host = host;
        self.port = port;
        self.username = username;
        self.password = password;
        self.from = from;
        self.headers = headers;
        self.interval = max(interval, 60);

        zThread(block: {
            while(true) {
                sleep(self.interval);

                self._lock.lock();
                self.sentCounter = 0;
                self._lock.unlock();

                self.send();
            }
        }).start();
    }

    func add(email : Email) {
        email.host = self;

        self._lock.lock();
        self.queue.append(email);
        self._lock.unlock();

        self.send();
    }

    func send() {
        self._lock.lock();

        if ((self.sentCounter >= self.maxSentInInterval) || (self.queue.count == 0)) {
            self._lock.unlock();
            return;
        }

        if let email = self.queue.remove(0) {
            self.sentCounter += 1;
            self._lock.unlock();

            sendEmail(email: email);
        }

        self.send();
    }

    private func sendEmail(email : Email) {
        let startSend = NSDate();
        if let handle = curl_easy_init() {
            var recipients: UnsafeMutablePointer<curl_slist>?;

            defer {
                curl_easy_cleanup(handle);

                if recipients != nil {
                    curl_slist_free_all(recipients);
                }
            }

            emailHelperSetOptString(handle, CURLOPT_URL, stringToChars("smtp://\( self.host ):\( self.port )"));
            emailHelperSetOptUseSSL(handle);
            emailHelperSetOptInt(handle, CURLOPT_SSL_VERIFYPEER, 0);
            emailHelperSetOptInt(handle, CURLOPT_SSL_VERIFYHOST, 0);

            emailHelperSetOptString(handle, CURLOPT_USERNAME, stringToChars(self.username));
            emailHelperSetOptString(handle, CURLOPT_PASSWORD, stringToChars(self.password));
            emailHelperSetOptString(handle, CURLOPT_MAIL_FROM, stringToChars(EmailHost.addBrackets(self.from)));

            let recip = email.to.split(separator : ",");
            for v in recip {
                recipients = curl_slist_append(recipients, stringToChars(EmailHost.addBrackets(v.trim())));
            }

            if ( email.cc != nil ) {
                recipients = curl_slist_append(recipients, stringToChars(EmailHost.addBrackets(email.cc!)));
            }

            emailHelperSetOptHeaders(handle, CURLOPT_MAIL_RCPT, recipients);

            emailHelperSetOptReadFunc(handle) { (buf: UnsafeMutablePointer<Int8>?, size: Int, nMemb: Int, privateData: UnsafeMutableRawPointer?) -> Int in
                if (size * nMemb == 0) {
                    return 0;
                }

                let p = privateData?.assumingMemoryBound(to: Email.self).pointee;
                if let pemail = p {

                    if (pemail.sendStatus == nil) {
                        return 0;
                    }

                    var resData : Data?;
                    switch (pemail.sendStatus!) {
                        case .MAILPART_HEADER :
                            let formatter = DateFormatter();
                            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZ";
                            formatter.locale = Locale(identifier : "en_US");

                            let recip = pemail.to.split(separator : ",");
                            var emailTo = [String]();
                            for v in recip {
                                emailTo.append(EmailHost.addBrackets(v.trim()));
                            }

                            var strs : [String] = [
                                    "User-Agent: swift-email-sender v\(EmailQueue.VERSION)",
                                    "Date: \(formatter.string(from: Date()))",
                                    "From: \(EmailHost.addBrackets(pemail.host!.from))",
                                    "To: \(emailTo.joined(separator : ", "))"
                            ];

                            if (pemail.cc != nil) {
                                strs.append("Cc: <\(pemail.cc!)>")
                            }

                            strs.append("Subject: \(pemail.subject)");

                            if let head = pemail.host!.headers {
                                strs += head;
                            }

                            strs.append("MIME-Version: 1.0");
                            strs.append("Content-Type: multipart/alternative; boundary=\"\(pemail.boundary_body)\"");

                            resData = StringUtils.toNullTerminatedUtf8String(strs.joined(separator: "\r\n") + "\r\n");
                            break;

                        case .MAILPART_BODY :
                            resData = StringUtils.toNullTerminatedUtf8String(pemail.getBody().joined(separator: "\r\n"));
                            break;
                    }

                    pemail.sendStatus = pemail.sendStatus!.next();
                    if (resData != nil) {
                        return EmailHost.fillBuffer(data : resData!, buffer : UnsafeRawPointer(buf!).assumingMemoryBound(to: UInt8.self), length: size * nMemb);
                    } else {
                        return 0;
                    }

                } else {
                    // Не удалось получить объект письма
                    print("Cannot get email object");
                    return 0;
                }
            }

            var vemail = email;
            withUnsafeMutablePointer(to: &vemail) {
                ptr in
                emailHelperSetOptReadData(handle, ptr);
                emailHelperSetOptInt(handle, CURLOPT_UPLOAD, 1);
                curl_easy_perform(handle);
            }
        }
    }

    private static func addBrackets(_ s : String) -> String {
        if (s.preg_test(pattern : "[<>]+")) {
            return s;
        }

        return "<\(s)>";
    }

    static func fillBuffer(data : Data, buffer: UnsafePointer<UInt8>, length: Int) -> Int {
        let localData = NSMutableData(capacity: 4096) ?? NSMutableData();
        localData.append(data);

        let result = min(length, localData.length);
        let bytes = localData.bytes.assumingMemoryBound(to: UInt8.self) + 0;
        UnsafeMutableRawPointer(mutating: buffer).copyBytes(from: bytes, count: result);

        return result;
    }

    private func stringToChars(_ st : String) -> UnsafeMutablePointer<Int8> {
        if let temp = StringUtils.toNullTerminatedUtf8String(st) {
            let bytes = temp.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> UnsafeMutablePointer<Int8> in
                return UnsafeMutablePointer<Int8>(OpaquePointer(pointer));
            }

            return bytes;
        } else {
            return UnsafeMutablePointer<Int8>(mutating: [Int8]());
        }
    }
}