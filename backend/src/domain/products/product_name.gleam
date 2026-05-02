import domain/basics/conditional
import domain/basics/non_empty_set
import gleam/string

const max_length = 255

pub opaque type T {
  ProductName(value: String)
}

pub type ValidationError {
  Empty
  LeadingOrTrailingWhitespace
  InvalidCharacters
  TooLong
}

fn contains_forbidden_characters(raw: String) -> Bool {
  string.contains(raw, "\n")
  || string.contains(raw, "\r")
  || string.contains(raw, "\t")
}

pub fn new(raw: String) -> Result(T, non_empty_set.T(ValidationError)) {
  let errors =
    []
    |> conditional.prepend_if(raw == "", Empty)
    |> conditional.prepend_if(
      raw != string.trim(raw),
      LeadingOrTrailingWhitespace,
    )
    |> conditional.prepend_if(
      contains_forbidden_characters(raw),
      InvalidCharacters,
    )
    |> conditional.prepend_if(string.length(raw) > max_length, TooLong)

  case non_empty_set.from_list(errors) {
    Error(_) -> Ok(ProductName(raw))
    Ok(validation_errors) -> Error(validation_errors)
  }
}

/// Canonical constructor for user-provided input.
/// Trims leading/trailing whitespace and then applies strict validation.
pub fn from_user_input(
  raw: String,
) -> Result(T, non_empty_set.T(ValidationError)) {
  raw
  |> string.trim
  |> new
}

pub fn value(name: T) -> String {
  name.value
}
