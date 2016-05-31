import Foundation
import Darwin

let queue = EmailQueue();
queue.addHost(
    alias : "test",
    host : "smtp.gmail.com",
    port : 587,
    username : "noreply@ikalogs.ru",
    password: "q=p+dqKWiy6Z",
    from : "noreply@ikalogs.ru"
);

var email = Email(subject: "test subject", to : "zig1375@gmail.com");
email.text = "test text \n проверка";
email.html = "test html <br/><b> проверка </b>";

queue.addEmail(alias : "test", email : email);
sleep(60)