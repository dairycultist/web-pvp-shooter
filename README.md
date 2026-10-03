# web-pvp-shooter

literally just sending raw binary via [UDP](https://docs.godotengine.org/en/stable/classes/class_packetpeerudp.html#class-packetpeerudp)

https://gist.github.com/sid24rane/6e6698e93360f2694e310dd347a2e2eb

Client made in Godot for web platforms with a server backend in Node.js.

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

https://mindlessdev.itch.io/prototypegrid
