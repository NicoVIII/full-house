import domain/stock_items/best_before_date
import gleeunit/should

pub fn new_accepts_valid_date_test() {
  let assert Ok(date) = best_before_date.new("2026-10-12")

  should.equal(best_before_date.value(date), "2026-10-12")
}

pub fn new_rejects_missing_date_test() {
  should.equal(best_before_date.new(""), Error(best_before_date.Empty))
}

pub fn new_rejects_invalid_format_test() {
  should.equal(
    best_before_date.new("12-10-2026"),
    Error(best_before_date.InvalidFormat),
  )
}

pub fn new_rejects_invalid_calendar_date_test() {
  should.equal(
    best_before_date.new("2026-02-30"),
    Error(best_before_date.InvalidDate),
  )
}

pub fn new_accepts_leap_day_in_leap_year_test() {
  let assert Ok(date) = best_before_date.new("2028-02-29")

  should.equal(best_before_date.value(date), "2028-02-29")
}
