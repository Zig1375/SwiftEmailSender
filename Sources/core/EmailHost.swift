import Foundation
import EmailCurl

class EmailHost {
    private let accessQueue = dispatch_queue_create("SynchronizedDictionaryAccess", DISPATCH_QUEUE_SERIAL);
    private var sentCounter : UInt32 = 0;

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

        let _ = Thread() {
            sleep(self.interval);
            self.sentCounter = 0;
            self.send();
        };
    }

    func add(email : Email) {
        email.host = self;
        self.queue.append(email);
    }

    func send() {
        if ((self.sentCounter >= self.maxSentInInterval) || (self.queue.count == 0)) {
            return;
        }

        if let email = self.queue.remove(0) {
            sendEmail(email: email);
        }

        self.sentCounter += 1;
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

            curlHelperSetOptString(handle, CURLOPT_URL, stringToChars("smtp://\( self.host ):\( self.port )"));
            curlHelperSetOptUseSSL(handle);
            curlHelperSetOptInt(handle, CURLOPT_SSL_VERIFYPEER, 0);
            curlHelperSetOptInt(handle, CURLOPT_SSL_VERIFYHOST, 0);

            curlHelperSetOptString(handle, CURLOPT_USERNAME, stringToChars(self.username));
            curlHelperSetOptString(handle, CURLOPT_PASSWORD, stringToChars(self.password));
            curlHelperSetOptString(handle, CURLOPT_MAIL_FROM, stringToChars("<\(self.from)>"));

            recipients = curl_slist_append(recipients, stringToChars("<\(email.to)>"));

            if ( email.cc != nil ) {
                recipients = curl_slist_append(recipients, stringToChars("<\(email.cc!)>"));
            }

            curlHelperSetOptHeaders(handle, CURLOPT_MAIL_RCPT, recipients);

            curlHelperSetOptReadFunc(handle) { (buf: UnsafeMutablePointer<Int8>!, size: Int, nMemb: Int, privateData: UnsafeMutablePointer<Void>!) -> Int in
                if (size * nMemb == 0) {
                    return 0;
                }

                let p = UnsafePointer<Email>(privateData);
                if let pemail = p?.pointee {

                    if (pemail.sendStatus == nil) {
                        return 0;
                    }

                    var resData : NSData?;
                    switch (pemail.sendStatus!) {
                        case .MAILPART_HEADER :
                            let formatter = NSDateFormatter();
                            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZ";
                            formatter.locale = NSLocale(localeIdentifier : "en_US");

                            var strs : [String] = [
                                "User-Agent: swift-email-sender v\(EmailQueue.VERSION)",
                                "Date: \(formatter.string(from: NSDate()))",
                                "From: <\(pemail.host!.from)>",
                                "To: <\(pemail.to)>"
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
                        return EmailHost.fillBuffer(data : resData!, buffer : UnsafeMutablePointer<UInt8>(buf), length: size * nMemb);
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
            withUnsafeMutablePointer(&vemail) {
                ptr in
                curlHelperSetOptReadData(handle, ptr);
                curlHelperSetOptInt(handle, CURLOPT_UPLOAD, 1);
                curl_easy_perform(handle);
            }
        }
    }

    static func fillBuffer(data : NSData, buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Int {
        let result = min(length, data.length) - 1;
        memcpy(buffer, data.bytes + 0, Int(result));
        return result;
    }

    private func stringToChars(_ st : String) -> UnsafeMutablePointer<Int8> {
        if let temp = StringUtils.toNullTerminatedUtf8String(st) {
            return UnsafeMutablePointer<Int8>(temp.bytes);
        } else {
            return UnsafeMutablePointer<Int8>([Int8]());
        }
    }
}
