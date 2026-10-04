var server = require("dgram").createSocket("udp4");

function on_error(error) {
    if (!error)
        return;
    console.log("Error: " + error);
    server.close();
}

function send(client, msg) {
    server.send(msg, client.port, client.address, on_error);
}

class Player {
  
    constructor(keepalive) {

        // will immediately be updated by the client so the initial values don't matter
        this.x = 0.0;
        this.y = 0.0;
        this.z = 0.0;
        this.pitch = 0.0;
        this.yaw = 0.0;

        // unix time of the last message; if it's over a threshold we can assume
        // they disconnected, allowing us to free up the ID for future use
        this.keepalive = Date.now();
    }
}

// player id => Player
var players = {};

// message type => handlers
var message_types = {
    "conn": {
        "update_server": (client, player_id, content) => {

            if (players[content] && Date.now() - players[content].keepalive < 5000) { // hasn't been 5 seconds
                send(client, "TAKEN");
                return;
            }

            players[content] = new Player();
            send(client, "OK");
        }
    },
    "players": {
        "update_client": (client, player_id) => {

            var remote_players = Object.keys(players);

            // don't want to return the local player's id in the list of remote player ids
            remote_players.splice(remote_players.indexOf(player_id), 1);

            if (remote_players.length == 0)
                return;

            console.log(remote_players.join(","));

            send(client, "players:" + remote_players.join(","));
        }
    },
    "pos": {
        "update_server": (client, player_id, content) => {
            const [x, y, z] = content.split(",");
            players[player_id].x = x;
            players[player_id].y = y;
            players[player_id].z = z;
        },
        "update_client": (client, player_id) => {
            send(client, "pos:" + player_id + ":" + players[player_id].x + "," + players[player_id].y + "," + players[player_id].z);
        }
    },
    "rot": {
        "update_server": (client, player_id, content) => {
            const [pitch, yaw] = content.split(",");
            players[player_id].pitch = pitch;
            players[player_id].yaw = yaw;
        },
        "update_client": (client, player_id) => {
            send(client, "rot:" + player_id + ":" + players[player_id].pitch + "," + players[player_id].yaw);
        }
    }
};

server.on("error", on_error);

server.on("message", (msg, client) => {

    msg = msg.toString(); // since it arrives as binary
    // console.log(`Received "${ msg }" (${ msg.length } bytes) from ${ client.address }:${ client.port }`);

    // client wants to update information on the server
    if (msg.includes(":")) {

        const [player_id, type, content] = msg.split(":");

        // if message is about a player, they must have first been requested
        if (!(players[player_id] || player_id === ""))
            return;

        if (players[player_id])
            players[player_id].keepalive = Date.now();

        if (message_types[type]["update_server"])
            message_types[type]["update_server"](client, player_id, content);
    
    // client wants to receive info from the server
    } else if (msg.includes(";")) {

        const [player_id, type] = msg.split(";");

        // if message is about a player, they must have first been requested
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
