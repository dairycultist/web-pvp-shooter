var server = require("dgram").createSocket("udp4");

function on_error(error) {
    if (!error)
        return;
    console.log("Error: " + error);
    server.close();
}

server.on("error", on_error);

server.on("message",function(msg, info) {

    console.log('Data received from client: ' + msg.toString());
    console.log('Received %d bytes from %s:%d\n',msg.length, info.address, info.port);

    // respond
    server.send("I am the server! I have responded!", info.port, info.address, on_error);
});

server.on("listening", function() {

    var address = server.address();
    console.log(`Server is up at: ${ address.address }:${ address.port } (${ address.family })`);
});

server.on("close", function() {
  console.log("Bye bye!");
});

server.bind(19132);
