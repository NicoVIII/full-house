import gleam/string

const max_length = 255

pub opaque type T {
  Barcode(value: String)
}

pub type ValidationError {
  Empty
  TooLong
}

pub fn new(raw: String) -> Result(T, ValidationError) {
  case raw {
    "" -> Error(Empty)
    _ ->
      case string.length(raw) > max_length {
        True -> Error(TooLong)
        False -> Ok(Barcode(raw))
      }
  }
}

pub fn from_user_input(raw: String) -> Result(T, ValidationError) {
  raw
  |> string.trim
  |> new
}

pub fn value(barcode: T) -> String {
  barcode.value
}
