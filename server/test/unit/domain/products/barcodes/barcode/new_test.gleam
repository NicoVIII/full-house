import domain/products/barcodes/barcode
import gleam/string
import gleeunit/should

pub fn accepts_valid_barcode_test() {
  let assert Ok(code) = barcode.new("5901234123457")

  should.equal(barcode.to_value(code), "5901234123457")
}

pub fn accepts_length_255_test() {
  let max_length = string.repeat("1", 255)
  let assert Ok(code) = barcode.new(max_length)

  should.equal(barcode.to_value(code), max_length)
}

pub fn rejects_empty_barcode_test() {
  should.equal(barcode.new(""), Error(barcode.Empty))
}

pub fn rejects_length_256_test() {
  let too_long = string.repeat("1", 256)

  should.equal(barcode.new(too_long), Error(barcode.TooLong))
}

pub fn rejects_space_in_barcode_test() {
  should.equal(barcode.new(" 5901234123457 "), Error(barcode.InvalidCharacters))
}

pub fn rejects_comma_test() {
  should.equal(barcode.new("123,456"), Error(barcode.InvalidCharacters))
}

pub fn rejects_control_character_test() {
  should.equal(barcode.new("123\t456"), Error(barcode.InvalidCharacters))
}

pub fn rejects_non_ascii_test() {
  should.equal(barcode.new("caf\u{00E9}"), Error(barcode.InvalidCharacters))
}

pub fn accepts_symbols_test() {
  let assert Ok(code) = barcode.new("ABC-123.45/6+7")

  should.equal(barcode.to_value(code), "ABC-123.45/6+7")
}
