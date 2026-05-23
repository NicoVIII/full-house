import domain/basics/non_empty_set
import domain/products/product_name
import gleeunit/should

pub fn new_rejects_leading_and_trailing_whitespace_test() {
  let result = product_name.new("  Latte  ")

  should.equal(
    result,
    Error(non_empty_set.new(product_name.LeadingOrTrailingWhitespace)),
  )
}

pub fn from_user_input_trims_whitespace_test() {
  let assert Ok(name) = product_name.from_user_input("  Latte  ")

  should.equal(product_name.value(name), "Latte")
}

pub fn from_user_input_rejects_whitespace_only_name_test() {
  let result = product_name.from_user_input("   ")

  should.equal(result, Error(non_empty_set.new(product_name.Empty)))
}

pub fn new_accepts_already_trimmed_name_test() {
  let assert Ok(name) = product_name.new("Latte")

  should.equal(product_name.value(name), "Latte")
}

pub fn new_rejects_tab_character_test() {
  let result = product_name.new("Lat\tte")

  should.equal(result, Error(non_empty_set.new(product_name.InvalidCharacters)))
}

pub fn new_rejects_newline_character_test() {
  let result = product_name.new("Latte\nMocha")

  should.equal(result, Error(non_empty_set.new(product_name.InvalidCharacters)))
}

pub fn new_returns_all_validation_errors_test() {
  let result = product_name.new(" Latte\n")

  should.equal(
    result,
    Error(
      non_empty_set.new(product_name.LeadingOrTrailingWhitespace)
      |> non_empty_set.insert(product_name.InvalidCharacters),
    ),
  )
}
