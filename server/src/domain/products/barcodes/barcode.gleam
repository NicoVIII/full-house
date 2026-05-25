import gleam/regexp
import gleam/string

const max_length = 255

pub opaque type T {
  Barcode(value: String)
}

pub type ValidationError {
  Empty
  InvalidCharacters
  TooLong
}

fn has_only_allowed_chars(value: String) -> Bool {
  // Printable ASCII characters except space (0x20), comma (0x2C) and control characters (0x00-0x1F, 0x7F)
  let assert Ok(re) = regexp.from_string("^[\\x21-\\x2B\\x2D-\\x7E]+$")
  regexp.check(re, value)
}

pub fn new(value: String) -> Result(T, ValidationError) {
  case value {
    "" -> Error(Empty)
    _ ->
      case has_only_allowed_chars(value) {
        False -> Error(InvalidCharacters)
        True ->
          case string.length(value) > max_length {
            True -> Error(TooLong)
            False -> Ok(Barcode(value))
          }
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
