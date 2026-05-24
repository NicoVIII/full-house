import gleam/string

const max_length = 255

pub opaque type T {
  Barcode(value: String)
}

pub type ValidationError {
  Empty
  TooLong
}

pub fn new(value: String) -> Result(T, ValidationError) {
  case value {
    "" -> Error(Empty)
    _ ->
      case string.length(value) > max_length {
        True -> Error(TooLong)
        False -> Ok(Barcode(value))
      }
  }
}

pub fn from_user_input(input: String) -> Result(T, ValidationError) {
  input
  |> string.trim
  |> new
}

pub fn to_value(barcode: T) -> String {
  barcode.value
}
