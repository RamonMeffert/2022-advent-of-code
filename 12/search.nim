import sequtils
import std/strformat
import std/heapqueue
import std/deques
import std/tables
import std/options
import map
import coordinate

proc print_visited(map: Map, came_from: Table[Coordinate, Coordinate]) =
    var heatMap = newSeqWith(map.height, repeat('.', map.width))
    for cur in came_from.values:
        heatMap[cur.y][cur.x] = '#'

    for y in 0 ..< map.height:
        for x in 0 ..< map.width:
            if map.goal.x == x and map.goal.y == y:
                write(stdout, 'G')
            elif map.start.x == x and map.start.y == y:
                write(stdout, 'S')
            else:
                write(stdout, heatMap[y][x])
        write(stdout, "\n")

proc print_visited_to_file(map: Map, came_from: Table[Coordinate, Coordinate]) =
    let f = io.open("visited.pgm", fmWrite) # fmWrite is the file mode constant 
    defer: f.close()

    f.writeLine("P2")
    f.writeLine($map.width & " " & $map.height)
    f.writeLine("25")
    
    var heatMap = newSeqWith(map.height, repeat("  0", map.width))
    for cur in came_from.values:
        heatMap[cur.y][cur.x] = " 25"

    for y in 0 ..< map.height:
        for x in 0 ..< map.width:
            f.write(heatMap[y][x])
        f.write("\n")

proc reconstruct_path(prev: Table[Coordinate, Coordinate], current: Coordinate): Deque[Coordinate] =
    var path: Deque[Coordinate]
    var u = current

    # for key in prev.keys:
    #     let to = prev[key]
    #     write(stdout, &"{key.x:>3} {key.y:>3} {key.h:>3} → {to.x:>3} {to.y:>3} {to.h:>3}\n")

    while prev.hasKey(u):
        path.addFirst(u)
        u = prev[u]

    return path

proc a_star*(map: Map): Option[Deque[Coordinate]]  =
    let f_start = euclidean_distance(map.start, map.goal)

    var open_set: HeapQueue[Node] = [Node(f: f_start, c: map.start)].toHeapQueue

    var came_from: Table[Coordinate, Coordinate] = initTable[Coordinate, Coordinate]()

    var g_score: Table[Coordinate, int] = { map.start: 0 }.toTable

    var f_score: Table[Coordinate, int] = { map.start: f_start }.toTable

    while open_set.len != 0:
        let current: Node = open_set[0]

        if current.c == map.goal:
            return some(reconstruct_path(came_from, current.c))

        discard open_set.pop()

        for neighbour in get_neighbours(map, current.c):
            let tentative_g_score = g_score[current.c] + euclidean_distance(current.c, neighbour)

            if not g_score.hasKey(neighbour):
                g_score[neighbour] = high(int)

            if tentative_g_score < g_score[neighbour]:
                let f_neighbour = euclidean_distance(neighbour, map.goal)
                let n_neighbour = Node(f: f_neighbour, c: neighbour)
                came_from[neighbour] = current.c
                g_score[neighbour] = tentative_g_score
                f_score[neighbour] = tentative_g_score + f_neighbour

                if open_set.find(n_neighbour) == -1:
                    open_set.push(n_neighbour)

    print_visited(map, came_from)
    return none(Deque[Coordinate])

proc dijkstra*(map: Map): Option[Deque[Coordinate]] =
    var dist: Table[Coordinate, int]
    var prev: Table[Coordinate, Coordinate]
    var q: HeapQueue[Node]

    for y in 0 ..< map.height:
        for x in 0 ..< map.width:
            let h = map.elevation[y][x]
            let v = (x, y, h)
            var d = high(int)
            if v == map.start:
                d = 0
            
            dist[v] = d
            q.push(Node(f: d, c: v))

    while q.len != 0:
        # Remove and return best vertex
        let u = q.pop

        # for each neighbor v of u...
        for v in get_neighbours(map, u.c):
            let i_old_v = q.find(Node(f: dist[v], c: v))
            let alt = if dist[u.c] == high(int): high(int) else: dist[u.c] + 1 # grid. so d is always 1

            if alt < dist[v]:
                dist[v] = alt
                prev[v] = u.c
                # replace v in q by deleting the old one and inserting a new
                # version with a changed priority
                # This is the same as decreasing the priority
                if i_old_v != -1:
                    q.del(i_old_v)
                q.push(Node(f: alt, c: v))

    print_visited_to_file(map, prev)
    return some(reconstruct_path(prev, map.goal))