const default_value = 20

const min_value = 1

const max_value = 100

pub opaque type T {
  Limit(value: Int)
}

pub fn new(raw: Int) -> Result(T, Nil) {
  case raw >= min_value && raw <= max_value {
    True -> Ok(Limit(raw))
    False -> Error(Nil)
  }
}

pub fn new_exn(raw: Int) -> T {
  case new(raw) {
    Ok(l) -> l
    Error(_) -> panic as "PageLimit must be between 1 and 100"
  }
}

pub fn default() -> T {
  Limit(default_value)
}

pub fn value(l: T) -> Int {
  l.value
}
