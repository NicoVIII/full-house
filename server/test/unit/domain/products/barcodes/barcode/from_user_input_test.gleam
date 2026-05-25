import domain/products/barcodes/barcode
import gleam/string
import gleeunit/should
import qcheck

const test_count = 200

fn property_config() -> qcheck.Config {
  qcheck.default_config()
  |> qcheck.with_test_count(test_count)
}

pub fn trims_surrounding_whitespace_test() {
  let assert Ok(code) = barcode.from_user_input("  5901234123457  ")

  should.equal(barcode.to_value(code), "5901234123457")
}

pub fn trims_tabs_and_newlines_test() {
  let assert Ok(code) = barcode.from_user_input("\n\t5901234123457\t\n")

  should.equal(barcode.to_value(code), "5901234123457")
}

pub fn rejects_blank_barcode_test() {
  should.equal(barcode.from_user_input("   \n  "), Error(barcode.Empty))
}

pub fn rejects_too_long_after_trim_test() {
  let too_long = string.repeat("1", 256)

  should.equal(
    barcode.from_user_input("  " <> too_long <> "  "),
    Error(barcode.TooLong),
  )
}

pub fn rejects_comma_after_trim_test() {
  should.equal(
    barcode.from_user_input("  12,34  "),
    Error(barcode.InvalidCharacters),
  )
}

pub fn matches_trim_then_new_property_test() {
  qcheck.run(property_config(), qcheck.string(), fn(raw) {
    assert barcode.from_user_input(raw) == barcode.new(string.trim(raw))
  })
}
