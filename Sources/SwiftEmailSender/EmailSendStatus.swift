import Foundation

enum EmailSendStatus : Int {
    case MAILPART_HEADER = 0;
    case MAILPART_BODY = 1;

    func next() -> EmailSendStatus? {
        return EmailSendStatus(rawValue: self.rawValue + 1);
    }
}
