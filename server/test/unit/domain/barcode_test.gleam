import domain/products/barcode
import gleam/string
import gleeunit/should

pub fn new_accepts_valid_barcode_test() {
  let assert Ok(code) = barcode.new("5901234123457")

  should.equal(barcode.value(code), "5901234123457")
}

pub fn from_user_input_trims_surrounding_whitespace_test() {
  let assert Ok(code) = barcode.from_user_input("  5901234123457  ")

  should.equal(barcode.value(code), "5901234123457")
}

pub fn new_rejects_empty_barcode_test() {
  should.equal(barcode.new(""), Error(barcode.Empty))
}

pub fn from_user_input_rejects_blank_barcode_test() {
  should.equal(barcode.from_user_input("   \n  "), Error(barcode.Empty))
}

pub fn new_rejects_too_long_barcode_test() {
  let too_long = string.repeat("1", 256)

  should.equal(barcode.new(too_long), Error(barcode.TooLong))
}
