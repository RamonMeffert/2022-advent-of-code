import std/strformat
import math

type
    Coordinate* = tuple[x: int, y: int, h: int]

proc `$`*(a: Coordinate): string =
    return &"({a.x:>3}, {a.y:>3}, {a.h:>3})"

type
    Node* = object
        f*: int
        c*: Coordinate

proc `<`*(a, b: Node): bool = a.f < b.f

# "3d" manhattan distance
proc manhattan_distance*(c1: Coordinate, c2: Coordinate): int =
    let dx = if c1.x > c2.x: c1.x - c2.x else: c2.x - c1.x
    let dy = if c1.y > c2.y: c1.y - c2.y else: c2.y - c1.y
    let dh = if c1.h > c2.h: c1.h - c2.h else: c2.h - c1.h

    return (dx + dy + dh)

proc euclidean_distance*(c1: Coordinate, c2: Coordinate): int =
    int(sqrt(pow(float(c1.x - c2.x), 2) + pow(float(c1.y - c2.y), 2) + pow(float(c1.h - c2.h), 2)))
