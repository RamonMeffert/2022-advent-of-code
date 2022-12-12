import nibble.{Parser}
import gleam/function
import gleam/list
import gleam/io
import gleam/int

// https://blog.hayleigh.dev/phantom-types-in-gleam
pub opaque type Id(a) {
  Id(Int)
}

pub fn new_id(id) -> Id(a) {
  Id(id)
}

pub fn id_to_string(id: Id(a)) -> String {
  let Id(val) = id
  "Monkey " <> int.to_string(val)
}

pub fn id_increase(id: Id(a)) -> Id(a) {
  let Id(val) = id
  Id(val + 1)
}

pub type Monkey {
  Monkey(
    id: Id(Monkey),
    worry_levels: List(Int),
    inspect: fn(Int) -> Int,
    inspect_count: Int,
    find_target: fn(Int) -> Id(Monkey),
  )
}

pub fn new_monkey(
  id: Int,
  worry_levels: List(Int),
  inspect: fn(Int) -> Int,
  find_target: fn(Int) -> Int,
) {
  Monkey(
    id: new_id(id),
    worry_levels: worry_levels,
    inspect: inspect,
    inspect_count: 0,
    find_target: function.compose(find_target, new_id),
  )
}

pub fn parse(in: String) -> Monkey {
  let parser =
    nibble.succeed(function.curry4(new_monkey))
    |> parse_id()
    |> parse_items()
    |> parse_operation()
    |> parse_test()

  let result = nibble.run(in, parser)

  let errors = case result {
    Error(ls) -> ls
    _ -> []
  }

  list.map(errors, io.debug)

  assert Ok(monkey) = result

  monkey
}

fn parse_id(parser: Parser(fn(Int) -> b, c)) -> Parser(b, c) {
  parser
  |> nibble.drop(nibble.string("Monkey"))
  |> nibble.drop(nibble.whitespace())
  |> nibble.keep(nibble.int())
  |> nibble.drop(nibble.grapheme(":"))
  |> nibble.drop(nibble.whitespace())
}

fn parse_items(parser: Parser(fn(List(Int)) -> b, c)) -> Parser(b, c) {
  parser
  |> nibble.drop(nibble.string("Starting items:"))
  |> nibble.keep(nibble.many(
    nibble.succeed(fn(x) -> Int { x })
    |> nibble.drop(nibble.whitespace())
    |> nibble.keep(nibble.int()),
    nibble.grapheme(","),
  ))
  |> nibble.drop(nibble.whitespace())
}

fn parse_operation(parser: Parser(fn(fn(Int) -> Int) -> b, c)) -> Parser(b, c) {
  parser
  |> nibble.drop(nibble.string("Operation: new = old "))
  |> nibble.keep(nibble.one_of([
    nibble.succeed(fn(x) { x * x })
    |> nibble.drop(nibble.grapheme("*"))
    |> nibble.drop(nibble.spaces())
    |> nibble.backtrackable()
    |> nibble.drop(nibble.string("old")),
    nibble.succeed(fn(x) { x + x })
    |> nibble.drop(nibble.grapheme("+"))
    |> nibble.drop(nibble.spaces())
    |> nibble.backtrackable()
    |> nibble.drop(nibble.string("old")),
    nibble.succeed(function.curry2(int.multiply))
    |> nibble.drop(nibble.grapheme("*"))
    |> nibble.drop(nibble.spaces())
    |> nibble.keep(nibble.int()),
    nibble.succeed(function.curry2(int.add))
    |> nibble.drop(nibble.grapheme("+"))
    |> nibble.drop(nibble.spaces())
    |> nibble.keep(nibble.int()),
  ]))
  |> nibble.drop(nibble.whitespace())
}

fn parse_test(parser: Parser(fn(fn(Int) -> Int) -> b, c)) -> Parser(b, c) {
  let target_fn = fn(divisor, true_target, false_target, n) {
    case n % divisor == 0 {
      True -> true_target
      False -> false_target
    }
  }

  parser
  |> nibble.keep(
    nibble.succeed(function.curry4(target_fn))
    |> nibble.drop(nibble.string("Test: divisible by "))
    |> nibble.keep(nibble.int())
    |> nibble.drop(nibble.whitespace())
    |> nibble.drop(nibble.string("If true: throw to monkey "))
    |> nibble.keep(nibble.int())
    |> nibble.drop(nibble.whitespace())
    |> nibble.drop(nibble.string("If false: throw to monkey "))
    |> nibble.keep(nibble.int())
    |> nibble.drop(nibble.whitespace()),
  )
}
