import domain/basics/non_empty_set
import domain/products/product_name
import gleam/list
import gleam/string
import qcheck

const test_count = 200

fn property_config() -> qcheck.Config {
  qcheck.default_config()
  |> qcheck.with_test_count(test_count)
}

fn contains_forbidden_characters(raw: String) -> Bool {
  string.contains(raw, "\n")
  || string.contains(raw, "\r")
  || string.contains(raw, "\t")
}

fn has_error(
  result: Result(product_name.T, non_empty_set.T(product_name.ValidationError)),
  error: product_name.ValidationError,
) -> Bool {
  case result {
    Ok(_) -> False
    Error(errors) ->
      errors
      |> non_empty_set.to_list
      |> list.any(fn(e) { e == error })
  }
}

pub fn from_user_input_matches_trim_then_new_property_test() {
  qcheck.run(property_config(), qcheck.string(), fn(raw) {
    assert product_name.from_user_input(raw)
      == product_name.new(string.trim(raw))
  })
}

pub fn new_empty_error_matches_exact_empty_input_property_test() {
  qcheck.run(property_config(), qcheck.string(), fn(raw) {
    let result = product_name.new(raw)
    let expected = raw == ""

    assert has_error(result, product_name.Empty) == expected
  })
}

pub fn new_error_classification_matches_input_conditions_property_test() {
  qcheck.run(property_config(), qcheck.string(), fn(raw) {
    let result = product_name.new(raw)
    let expected_whitespace = raw != string.trim(raw)
    let expected_invalid_characters = contains_forbidden_characters(raw)
    let expected_too_long = string.length(raw) > 255

    assert has_error(result, product_name.LeadingOrTrailingWhitespace)
      == expected_whitespace
    assert has_error(result, product_name.InvalidCharacters)
      == expected_invalid_characters
    assert has_error(result, product_name.TooLong) == expected_too_long
  })
}
