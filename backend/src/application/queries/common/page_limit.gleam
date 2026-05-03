import gleam/bool

const default_value = 20

const min_value = 1

const max_value = 100

pub opaque type T {
  Limit(value: Int)
}

pub type Error {
  GreaterThanZero
  LessThanOrEqualToMax
}

pub fn new(raw: Int) -> Result(T, Error) {
  use <- bool.guard(raw < min_value, Error(GreaterThanZero))
  use <- bool.guard(raw > max_value, Error(LessThanOrEqualToMax))

  Ok(Limit(raw))
}

pub fn default() -> T {
  Limit(default_value)
}

pub fn value(l: T) -> Int {
  l.value
}
