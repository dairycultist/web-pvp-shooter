var server = require("dgram").createSocket("udp4");

class Player { // Player, not Client, because we know nothing that links a player to a client (i.e. IP)
  
    constructor(keepalive) {

        // will immediately be updated by the client so the initial values don't matter
        this.x = 0.0;
        this.y = 0.0;
        this.z = 0.0;

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

var message_types = {
    "reqid": {
        "update_client": (client, player_id) => {

            for (const player_id of ["Player1", "Player2", "Player3", "Player4"]) {

                if (players[player_id] && Date.now() - players[player_id].keepalive > 5000)
                    players[player_id] = undefined;

                if (!players[player_id]) {

                    server.send("=" + player_id, client.port, client.address, on_error);
                    players[player_id] = new Player();
                    return;
                }
            }
        }
    },
    "pos": {
        "update_server": (client, player_id, content) => {
            const [x, y, z] = content.split(",");
            players[player_id].x = x;
            players[player_id].y = y;
            players[player_id].z = z;
        },
        "update_client": (player_id) => {
            server.send("pos:" + player_id + ":" + players[player_id].x + "," + players[player_id].y + "," + players[player_id].z, client.port, client.address, on_error);
        }
    }
};

server.on("message", (msg, client) => {

    msg = msg.toString(); // since it arrives as binary
    console.log(`Received "${ msg }" (${ msg.length } bytes) from ${ client.address }:${ client.port }`);

    // client wants to update information about themself on the server
    if (msg.includes(":")) {

        const [player_id, type, content] = msg.split(":");

        // you must request a player id before using it!
        if (!players[player_id])
            return

        players[player_id].keepalive = Date.now();

        if (message_types[type]["update_server"])
            message_types[type]["update_server"](client, player_id, content);
    
    // client wants to receive info from the server (either about someone or just general info)
    } else if (msg.includes(";")) {

        const [player_id, type] = msg.split(";");

        // can't get info about a player that doesn't exist
        if (!(players[player_id] || player_id === ""))
            return;

        if (message_types[type]["update_client"])
            message_types[type]["update_client"](client, player_id);
    }
});

server.on("listening", function() {

    var address = server.address();
    console.log(`Server is up at: ${ address.address }:${ address.port } (${ address.family })`);
});

server.bind(19132);
