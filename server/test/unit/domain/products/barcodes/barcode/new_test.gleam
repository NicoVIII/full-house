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

pub fn does_not_trim_input_test() {
  let assert Ok(code) = barcode.new(" 5901234123457 ")

  should.equal(barcode.to_value(code), " 5901234123457 ")
}
