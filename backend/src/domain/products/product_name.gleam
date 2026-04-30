import gleam/string

const max_length = 255

pub opaque type T {
  ProductName(value: String)
}

pub type ValidationError {
  Empty
  TooLong
}

pub fn new(raw: String) -> Result(T, ValidationError) {
  let trimmed = string.trim(raw)

  case trimmed == "" {
    True -> Error(Empty)
    False ->
      case string.length(trimmed) > max_length {
        True -> Error(TooLong)
        False -> Ok(ProductName(trimmed))
      }
  }
}

pub fn new_exn(raw: String) -> T {
  case new(raw) {
    Ok(name) -> name
    Error(Empty) -> panic as "ProductName must not be empty"
    Error(TooLong) -> panic as "ProductName must be 255 characters or less"
  }
}

pub fn value(name: T) -> String {
  name.value
}
