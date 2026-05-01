import application/queries/page_limit

pub opaque type T {
  Offset(value: Int)
}

pub fn new(raw: Int) -> Result(T, Nil) {
  case raw >= 0 {
    True -> Ok(Offset(raw))
    False -> Error(Nil)
  }
}

pub fn new_exn(raw: Int) -> T {
  case new(raw) {
    Ok(o) -> o
    Error(_) -> panic as "PageOffset must be non-negative"
  }
}

pub fn default() -> T {
  Offset(0)
}

pub fn value(o: T) -> Int {
  o.value
}

pub fn next(current: T, limit: page_limit.T) -> T {
  Offset(current.value + page_limit.value(limit))
}
