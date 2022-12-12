import monkey.{Id, Monkey}
import gleam/erlang/file
import gleam/string
import gleam/list
import gleam/io
import gleam/int
import gleam/map.{Map}
import gleam/function
import gleam/result
import gleam/order
import gleam/option.{None, Some}

pub fn main() {
  assert Ok(contents) = file.read("testin")

  let monkeys =
    contents
    |> string.split("\n\n")
    |> list.map(monkey.parse)

  let monkeys = do_rounds(monkeys, 20)
  let mb_level = find_monkey_business_level(monkeys)

  print_item_distribution(monkeys)
  io.println("")
  print_inspection_counts(monkeys)
  io.println("")
  io.println(int.to_string(mb_level))
}

fn print_item_distribution(monkeys: List(Monkey)) {
  monkeys
  |> list.map(fn(m: Monkey) {
    io.println(
      monkey.id_to_string(m.id) <> ": " <> string.join(
        list.map(m.worry_levels, int.to_string),
        with: ", ",
      ),
    )
  })
}

fn print_inspection_counts(monkeys: List(Monkey)) {
  monkeys
  |> list.map(fn(m: Monkey) {
    io.println(
      monkey.id_to_string(m.id) <> " inspected items " <> int.to_string(
        m.inspect_count,
      ) <> " times",
    )
  })
}

fn find_monkey_business_level(monkeys: List(Monkey)) {
  monkeys
  |> list.map(fn(m) { m.inspect_count })
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.take(2)
  |> list.reduce(int.multiply)
  |> result.unwrap(0)
}

fn do_rounds(monkeys: List(Monkey), num_rounds: Int) {
  case num_rounds > 0 {
    True -> do_rounds(monkey_business(monkeys), num_rounds - 1)
    False -> monkeys
  }
}

fn monkey_business(monkeys: List(Monkey)) -> List(Monkey) {
  monkey_business_helper(monkeys, monkey.new_id(0))
}

fn monkey_business_helper(monkeys: List(Monkey), current_id: Id(Monkey)) {
  assert Ok(current) =
    list.find(in: monkeys, one_that: fn(m) { m.id == current_id })

  let monkeys = monkey_throw(monkeys, current)
  let next_id = monkey.id_increase(current_id)
  case list.find(in: monkeys, one_that: fn(m) { m.id == next_id }) {
    Ok(_) -> monkey_business_helper(monkeys, next_id)
    Error(_) -> monkeys
  }
}

fn monkey_throw(monkeys: List(Monkey), current: Monkey) -> List(Monkey) {
  // save worry levels for processing
  let worry_levels = current.worry_levels
  // remove worry levels for current monkey
  let monkeys =
    list.filter_map(
      monkeys,
      fn(m) {
        case m.id == current.id {
          True -> Ok(Monkey(..m, worry_levels: list.new()))
          False -> Ok(m)
        }
      },
    )
  // Find what to trow where
  let to_throw: Map(Id(Monkey), List(Int)) =
    list.fold(
      worry_levels,
      map.new(),
      with: fn(acc, worry_level) {
        let new_level = current.inspect(worry_level) / 3
        let target = current.find_target(new_level)
        map.update(
          in: acc,
          update: target,
          with: fn(w) {
            case w {
              Some(val) -> [new_level, ..val]
              None -> [new_level]
            }
          },
        )
      },
    )

  // Throw items
  list.map(
    monkeys,
    with: fn(m) {
      case map.get(to_throw, m.id) {
        Ok(worry_levels) ->
          Monkey(
            ..m,
            worry_levels: list.append(
              m.worry_levels,
              list.reverse(worry_levels),
            ),
            inspect_count: m.inspect_count + list.length(worry_levels),
          )
        Error(_) -> m
      }
    },
  )
}
