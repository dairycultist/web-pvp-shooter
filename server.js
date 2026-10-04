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
  
    constructor() {

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

            if (Object.keys(players).length >= 8) {
                send(client, "FULL");
                return;
            }

            if (players[content]) {
                send(client, "TAKEN");
                return;
            }

            players[content] = new Player();
            send(client, "OK");

            console.log(`Player "${ content }" connected.`);
        }
    },
    "players": {
        "update_client": (client, player_id) => {

            // delete any seemingly disconnected players (haven't sent any messages in the past five seconds)
            for (const id of Object.keys(players)) {

                if (Date.now() - players[id].keepalive > 5000) {
                    delete players[id];
                    console.log(`Player "${ id }" disconnected.`);
                }
            }

            // get all players that aren't the requesting player
            var remote_players = Object.keys(players);
            remote_players.splice(remote_players.indexOf(player_id), 1);

            send(client, "players:" + remote_players.join(","));
        }
    },
    "xyzpy": {
        "update_server": (client, player_id, content) => {
            const [x, y, z, pitch, yaw] = content.split(",");
            players[player_id].x = x;
            players[player_id].y = y;
            players[player_id].z = z;
            players[player_id].pitch = pitch;
            players[player_id].yaw = yaw;
        },
        "update_client": (client, player_id) => {
            send(client, "xyzpy:" + player_id + ":" + players[player_id].x + "," + players[player_id].y + "," + players[player_id].z + "," + players[player_id].pitch + "," + players[player_id].yaw);
        }
    },
    "chat": {
        "update_server": (client, player_id, content) => {
            // server console outputs chat messages too
        },
        "update_client": (client, player_id) => {
            // clients periodically ask for every message the server has (server only stores last 5 or
            // so, 80ch max) as one supermessage (which includes player id of sender and linebreaks)
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
