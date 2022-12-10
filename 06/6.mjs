import * as fs from "fs/promises";

const input = await fs.readFile("input", "utf-8");
const window = [];
const windowSize = parseInt(process.argv[2]) || 4;

for(let i = 0; i < input.length; i++) {
    if (i > windowSize - 1) {
        const distinct = new Set(window);
        if (distinct.size === windowSize) {
            console.log(i, [...distinct].join(""));
            break;
        }
        window.shift(); // dequeue
    }
    window.push(input[i]); // enqueue
}
