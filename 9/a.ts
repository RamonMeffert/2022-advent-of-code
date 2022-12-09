import * as fs from "fs/promises";
import * as fs2 from "fs";

await main();

async function main() {
    const input = await fs.readFile("input", "utf-8");

    // Head and tail start at the same location
    let headLocation: Location = { x: 0, y: 0 };
    let tailLocation: Location = { x: 0, y: 0 };

    // Keep track of where the tail has been using a set
    let tailVisited: Set<string> = new Set();

    for (const move of input.split("\n")) {
        const [dir, num] = move.split(" ");
        for (let i = 0; i < parseInt(num); i++) {
            headLocation = moveHead(headLocation, dir);
            tailLocation = moveTail(tailLocation, headLocation);
            tailVisited.add(JSON.stringify(tailLocation));
        }
    }

    // Show a map of all tail visits
    saveTailVisitsMapToFile(tailVisited);
    console.log(tailVisited.size);
}

function moveHead(head: Location, direction: string): Location {
    switch (direction) {
        case "L": head.x--; break;
        case "R": head.x++; break;
        case "U": head.y--; break;
        case "D": head.y++; break;
    }

    return head;
}

function moveTail(tail: Location, head: Location): Location {
    const d = distance(tail, head);
    if (d <= Math.hypot(1, 1)) {
        return tail;
    } else {
        const dx = head.x - tail.x;
        const dy = head.y - tail.y;
        tail.x += Math.sign(dx);
        tail.y += Math.sign(dy);
        return tail;
    }
}

function distance(p1: Location, p2: Location) {
    return Math.hypot(p1.x - p2.x, p1.y - p2.y);
}

function saveTailVisitsMapToFile(visits: Set<string>, headLocation?: Location) {
    let minX = 0, minY = 0, maxX = 0, maxY = 0;
    for (const visit of visits) {
        const loc = JSON.parse(visit) as Location;
        minX = loc.x < minX ? loc.x : minX;
        minY = loc.y < minY ? loc.y : minY;
        maxX = loc.x > maxX ? loc.x : maxX;
        maxY = loc.y > maxY ? loc.y : maxY;
    }
    minX = Math.abs(minX);
    minY = Math.abs(minY);

    function setLocation(a: Array<Array<string>>, x: number, y: number, v: string) {
        if (a[y] === undefined) {
            a[y] = [];
        }
        a[y][x] = a[y][x] ? a[y][x] : v;
    }

    const visitLocations = new Array<Array<string>>();

    setLocation(visitLocations, minX, minY, "s");

    for (const visit of visits) {
        const loc = JSON.parse(visit) as Location;
        setLocation(visitLocations, minX + loc.x, minY + loc.y, "#");
    }

    if (headLocation) {
        setLocation(visitLocations, minX + headLocation.x, minY + headLocation.y, "H")
    }

    const output = fs2.createWriteStream("output");
    for (let row of visitLocations) {
        row[minX + maxX] = row[minX + maxX] ? row[minX + maxX] : ".";
        output.write(Array.from(row, x => x === undefined ? "." : x).join("") + "\n");
    }
}

interface Location {
    x: number,
    y: number
}
