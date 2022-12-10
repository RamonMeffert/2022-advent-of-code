use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let file = File::open("input").unwrap();
    let reader = BufReader::new(file);

    let mut cycle = 0;
    let mut x = 1;
    let mut signal_strength = 0;
    let mut screen: Vec<char> = Vec::with_capacity(240);

    for (_, line) in reader.lines().enumerate() {
        let line: String = line.unwrap();
        let vec: Vec<&str> = line.split(' ').collect();

        if vec[0] == "noop" {
            screen.push(get_screen_char(&cycle, &x));
            cycle += 1;
            signal_strength += get_signal_strength(&cycle, &x);
        } else if vec[0] == "addx" {
            for _ in 0..=1 {
                screen.push(get_screen_char(&cycle, &x));
                cycle += 1;
                signal_strength += get_signal_strength(&cycle, &x);
            }
            x += vec[1].parse::<i32>().unwrap();
        }
    }

    println!("Signal strength: {}", signal_strength);

    print_screen(&screen);
}

fn get_signal_strength(cycle: &i32, x: &i32) -> i32 {
    if (cycle - 20) % 40 == 0 {
        return x * cycle;
    }
    return 0;
}

fn get_screen_char(cycle: &i32, x: &i32) -> char {
    let crtpos = cycle % 40;
    let xpos = x;
    let draw = crtpos >= xpos - 1 && crtpos <= xpos + 1;

    if draw {
        return '#';
    }
    return '.';
}

fn print_screen(screen: &Vec<char>) {
    for i in 0..240 {
        print!("{}", screen[i]);
        if (i + 1) % 40 == 0 {
            println!();
        }
    }
}
