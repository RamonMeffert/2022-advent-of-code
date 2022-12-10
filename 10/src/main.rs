use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let file = File::open("input").unwrap();
    let reader = BufReader::new(file);

    let mut cycle = 0;
    let mut x = 1;
    let mut signal_strength = 0;

    for (_, line) in reader.lines().enumerate() {
        let line: String = line.unwrap();
        let vec: Vec<&str> = line.split(' ').collect();

        if vec[0] == "noop" {
            cycle += 1;
            signal_strength += get_signal_strength(&cycle, &x);
        } else if vec[0] == "addx" {
            for _ in 0..=1 {
                cycle += 1;
                signal_strength += get_signal_strength(&cycle, &x);
            }
            x += vec[1].parse::<i32>().unwrap();
        }
    }

    println!("{}", signal_strength);
}

fn get_signal_strength(cycle: &i32, x: &i32) -> i32 {
    if (cycle - 20) % 40 == 0 {
        return x * cycle;
    }
    return 0;
}
