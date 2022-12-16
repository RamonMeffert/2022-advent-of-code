import std/options
import std/deques

import coordinate
import map
import search

let start_map = parse_input()

save_map_image(start_map)

let shortest_path = dijkstra(start_map)

if shortest_path.isSome:
    let path: Deque[Coordinate] = shortest_path.get()
    echo "Found a path!"
    echo "Length: " & $path.len
    echo path
else:
    echo "No path found :("