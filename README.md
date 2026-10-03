# pvp-shooter

Desktop client made in Godot with a server backend in Node.js.

- 2v2 game
- a match is composed of many short rounds -- whichever team wins a round gets a point
- both teams spawn on opposite sides of a symmetrical map
- your goal is to either:
  - kill every member on the other team, or
  - reach the center of the map (where there's like a button or something)
- the map is structured such that:
  - there are a lot of vantage points into the center
  - routes to the center from spawn that are fast are also wide open
  - routes to the center from spawn that are slow have more cover
- the goal is to reach 5 (?) wins

debug texture https://mindlessdev.itch.io/prototypegrid

## Setting up a server

If you don't want to configure your router to port forward, you can use playit.gg.
Basically, you run `server.js` locally and give other people the address of your
playit.gg tunnel, which you should set up to forward to the local address/port
`127.0.0.1:19132`.

Or if you have a private server that accepts UDP traffic, use that instead (with
port 19132).
