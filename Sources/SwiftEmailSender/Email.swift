import Foundation

#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

public class Email {
    public let to   : String;
    public let cc   : String?;
    public let subject : String;
    public var html : String?;
    public var text : String?;

    internal var host : EmailHost?;
    internal let boundary_body = "=BODY=SEPARATOR=_\(random())_\(random())_\(random())_\(random())_=";

    /// Текущее состоянии отправки
    var sendStatus : EmailSendStatus? = EmailSendStatus.MAILPART_HEADER;

    public init(subject : String, to : String, cc : String? = nil) {
        self.subject = subject;
        self.to = to;
        self.cc = cc;
    }

    func validate() -> Bool {
        return ((self.html != nil) || (self.text != nil));
    }

    func getBody() -> [String] {
        var body = [String]();

        if let text = self.text {
            body += [
                "\r\n--\(self.boundary_body)",
                "Content-Type: text/plain; charset=utf-8",
                "Content-Transfer-Encoding: 8bit",
                "Content-Disposition: inline\r\n",
                text
            ];
        }

        if let html = self.html {
            body += [
                "\r\n--\(self.boundary_body)",
                "Content-Type: text/html; charset=utf-8",
                "Content-Transfer-Encoding: 8bit",
                "Content-Disposition: inline\r\n",
                html
            ];
        }

        body.append("\r\n--\(self.boundary_body)--\r\n");

        return body;
    }
}