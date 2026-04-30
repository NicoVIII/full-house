import application/page_limit
import application/page_offset
import qcheck

const test_count = 200

fn property_config() -> qcheck.Config {
  qcheck.default_config()
  |> qcheck.with_test_count(test_count)
}

pub fn page_limit_new_accepts_exact_valid_range_property_test() {
  let generator = qcheck.bounded_int(from: -200, to: 200)

  qcheck.run(property_config(), generator, fn(raw) {
    let result = page_limit.new(raw)
    let expected_is_ok = raw >= 1 && raw <= 100

    case result, expected_is_ok {
      Ok(_), True -> Nil
      Error(_), False -> Nil
      _, _ -> panic
    }
  })
}

pub fn page_offset_new_accepts_only_non_negative_property_test() {
  let generator = qcheck.bounded_int(from: -500, to: 500)

  qcheck.run(property_config(), generator, fn(raw) {
    let result = page_offset.new(raw)
    let expected_is_ok = raw >= 0

    case result, expected_is_ok {
      Ok(_), True -> Nil
      Error(_), False -> Nil
      _, _ -> panic
    }
  })
}

pub fn page_offset_next_adds_limit_value_property_test() {
  let generator =
    qcheck.tuple2(
      qcheck.bounded_int(from: 0, to: 10_000),
      qcheck.bounded_int(from: 1, to: 100),
    )

  qcheck.run(property_config(), generator, fn(values) {
    let #(offset_raw, limit_raw) = values

    let offset = page_offset.new_exn(offset_raw)
    let limit = page_limit.new_exn(limit_raw)
    let next = page_offset.next(offset, limit)

    assert page_offset.value(next)
      == page_offset.value(offset) + page_limit.value(limit)
  })
}
