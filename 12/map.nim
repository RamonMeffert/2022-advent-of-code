import std/strformat
import memfiles
import sequtils
import coordinate

type Map* = object
    width*: int
    height*: int
    start*: Coordinate
    goal*: Coordinate
    elevation*: seq[seq[int]]

proc parse_input*(): Map =
    var map = Map()

    for line in memSlices(memfiles.open("input")):
        inc(map.height)
        if line.size > map.width:
            map.width = line.size

    # Create matrix
    map.elevation = newSeqWith(map.height, newSeq[int](map.width))

    var y = 0
    for line in lines("input"):
        for x, letter in line:
            let val = case letter:
                of 'S':
                    map.goal = (x, y, 0)
                    0
                of 'E':
                    map.start = (x, y, 25)
                    25
                else:
                    int(letter) - int('a')
            map.elevation[y][x] = val
        y += 1

    return map

proc print_map*(map: Map) =
    for y in 0 ..< map.height:
        for x in 0 ..< map.width:
            write(stdout, char(map.elevation[y][x] + 97))
        write(stdout, "\n")

proc save_map_image*(map: Map) =
    let f = io.open("map.pgm", fmWrite) # fmWrite is the file mode constant 
    defer: f.close()

    f.writeLine("P2")
    f.writeLine($map.width & " " & $map.height)
    f.writeLine("25")

    for y in 0 ..< map.height:
        for x in 0 ..< map.width:
            f.write(&"{map.elevation[y][x]:>3}")
        f.write("\n")

proc valid_neighbour(map: Map, neighbour: Coordinate): bool =
    return
        neighbour.x >= 0 and
        neighbour.x < map.width and
        neighbour.y >= 0 and
        neighbour.y < map.height

proc get_neighbours*(map: Map, coordinate: Coordinate): seq[Coordinate] =
    var neighbours = newSeq[Coordinate]()

    for dx in [-1, 1]:
        var side = coordinate
        side.x += dx
        if valid_neighbour(map, side):
            side.h = map.elevation[side.y][side.x]
            if abs(coordinate.h - side.h) <= 1:
                neighbours.add(side)

    for dy in [-1, 1]:
        var side = coordinate
        side.y += dy

        if valid_neighbour(map, side):
            side.h = map.elevation[side.y][side.x]
            if abs(coordinate.h - side.h) <= 1:
                neighbours.add(side)

    return neighbours
