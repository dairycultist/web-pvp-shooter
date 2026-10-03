var server = require("dgram").createSocket("udp4");

class Player { // Player, not Client, because we know nothing that links a player to a client (i.e. IP)
  
    constructor(keepalive) {
        this.x = Math.random() * 6.0 - 3.0;
        this.y = 0.0;
        this.z = Math.random() * 6.0 - 3.0;

        // unix time of the last message; if it's over a threshold we can assume
        // they disconnected, allowing us to free up the ID for future use
        this.keepalive = Date.now();
    }
}

// maps player id to Player object
var players = {};

function on_error(error) {
    if (!error)
        return;
    console.log("Error: " + error);
    server.close();
}

server.on("error", on_error);

server.on("message", (msg, info) => {

    msg = msg.toString(); // since it arrives as binary

    console.log(`Received "${ msg }" (${ msg.length } bytes) from ${ info.address }:${ info.port }`);

    // client wants to update information about themself on the server
    if (msg.includes(":")) {

        const [player_id, type, content] = msg.split(":");

        players[player_id].keepalive = Date.now();

        switch (type) {
            
            case "pos":
                const [x, y, z] = content.split(",");
                players[player_id].x = x;
                players[player_id].y = y;
                players[player_id].z = z;
                break;
        }
    
    // client wants to receive info about someone else on the server
    } else if (msg.includes(";")) {

        const [player_id, type] = msg.split(":");

        switch (type) {
            
            case "pos":
                server.send("pos:" + player_id + ":" + players[player_id].x + "," + players[player_id].y + "," + players[player_id].z, info.port, info.address, on_error);
                break;
        }

    // client is requesting to be assigned a player id
    } else if (msg === "?") {

        for (const player_id of ["Player1", "Player2", "Player3", "Player4"]) {

            if (players[player_id] && Date.now() - players[player_id].keepalive > 5000)
                players[player_id] = undefined;

            if (!players[player_id]) {

                server.send("?" + player_id, info.port, info.address, on_error);
                players[player_id] = new Player();
                return;
            }
        }
    }
});

server.on("listening", function() {

    var address = server.address();
    console.log(`Server is up at: ${ address.address }:${ address.port } (${ address.family })`);
});

server.on("close", () => {
  console.log("Bye bye!");
});

server.bind(19132);
