var server = require("dgram").createSocket("udp4");

function on_error(error) {
    if (!error)
        return;
    console.log("Error: " + error);
    server.close();
}

server.on("error", on_error);

server.on("message", (msg, info) => {

    msg = msg.toString(); // since it arrives as binary

    console.log(`Received "${ msg }" (${ msg.length } bytes) from ${ info.address }:${ info.port }\n`);

    // respond appropriately
    if (msg === "rolereq")
        server.send("roleset1", info.port, info.address, on_error);
});

server.on("listening", function() {

    var address = server.address();
    console.log(`Server is up at: ${ address.address }:${ address.port } (${ address.family })`);
});

server.on("close", () => {
  console.log("Bye bye!");
});

server.bind(19132);
