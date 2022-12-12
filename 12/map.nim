import memfiles
import sequtils

type
    Map* = object
      start*: tuple[x: int, y: int]
      goal*: tuple[x: int, y: int]
      width*: int
      height*: int
      elevation*: seq[seq[int]]

proc parse_input(): Map =
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
                    map.start = (x, y)
                    0
                of 'E':
                    map.goal = (x, y)
                    25
                else:
                    int(letter) - int('a')
            map.elevation[y][x] = val
        y += 1

    return map