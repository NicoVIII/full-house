import gleam/bool

pub opaque type T {
  Offset(value: Int)
}

pub type Error {
  GreaterThanOrEqualToZero
}

pub fn new(raw: Int) -> Result(T, Error) {
  use <- bool.guard(raw < 0, Error(GreaterThanOrEqualToZero))
  Ok(Offset(raw))
}

pub fn default() -> T {
  Offset(0)
}

pub fn value(o: T) -> Int {
  o.value
}
