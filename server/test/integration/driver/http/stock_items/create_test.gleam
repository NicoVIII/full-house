import application/commands/create_stock_item
import common/product_id
import domain/stock_items/best_before_date
import domain/stock_items/stock_item
import gleam/function
import gleam/http
import gleam/json
import gleam/string
import integration/driver/http/stock_items/common
import integration/driver/http/testsetup
import wisp/simulate

pub fn create_stock_item_returns_201_test() {
  let expected_best_before_date = "2026-10-15"

  let handler =
    testsetup.build_handler_with_create_stock_item_ports(fn(_) {
      create_stock_item.Ports(
        does_product_exist: fn(_) { Ok(True) },
        create: fn(item) {
          let stock_item.StockItem(best_before_date: actual_date, ..) = item
          assert best_before_date.value(actual_date)
            == expected_best_before_date
          Ok(Nil)
        },
      )
    })

  let request =
    common.json_request(http.Post, "/api/v1/stock_items")
    |> simulate.json_body(
      json.object([
        #("product_id", json.string(common.valid_product_id)),
        #("best_before_date", json.string(expected_best_before_date)),
      ]),
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 201
  assert string.contains(body, "\"id\":")
  assert string.contains(
    body,
    "\"product_id\": \"018f4e1a-0000-7000-8000-000000000001\"",
  )
  assert string.contains(body, "\"best_before_date\": \"2026-10-15\"")
}

pub fn create_stock_item_missing_best_before_date_returns_400_test() {
  let handler =
    testsetup.build_handler_with_create_stock_item_ports(function.identity)

  let request =
    common.json_request(http.Post, "/api/v1/stock_items")
    |> simulate.json_body(
      json.object([
        #("product_id", json.string(common.valid_product_id)),
      ]),
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"message\":\"best_before_date is required\"")
}

pub fn create_stock_item_invalid_best_before_date_format_returns_400_test() {
  let handler =
    testsetup.build_handler_with_create_stock_item_ports(function.identity)

  let request =
    common.json_request(http.Post, "/api/v1/stock_items")
    |> simulate.json_body(
      json.object([
        #("product_id", json.string(common.valid_product_id)),
        #("best_before_date", json.string("15-10-2026")),
      ]),
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(
    body,
    "\"message\":\"best_before_date must use format YYYY-MM-DD\"",
  )
}

pub fn create_stock_item_product_does_not_exist_returns_400_test() {
  let handler =
    testsetup.build_handler_with_create_stock_item_ports(fn(ports) {
      create_stock_item.Ports(..ports, does_product_exist: fn(_) { Ok(False) })
    })

  let request =
    common.json_request(http.Post, "/api/v1/stock_items")
    |> simulate.json_body(
      json.object([
        #("product_id", json.string(common.missing_product_id)),
        #("best_before_date", json.string("2026-10-15")),
      ]),
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(
    body,
    "\"message\":\"product_id does not reference an existing product\"",
  )
}

pub fn create_stock_item_invalid_product_id_returns_400_test() {
  let handler =
    testsetup.build_handler_with_create_stock_item_ports(function.identity)

  let request =
    common.json_request(http.Post, "/api/v1/stock_items")
    |> simulate.json_body(
      json.object([
        #("product_id", json.string("not-a-uuid")),
        #("best_before_date", json.string("2026-10-15")),
      ]),
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"message\":\"product_id is not a valid UUID\"")
}

pub fn create_stock_item_invalid_calendar_date_returns_400_test() {
  let handler =
    testsetup.build_handler_with_create_stock_item_ports(function.identity)

  let request =
    common.json_request(http.Post, "/api/v1/stock_items")
    |> simulate.json_body(
      json.object([
        #("product_id", json.string(common.valid_product_id)),
        #("best_before_date", json.string("2026-02-30")),
      ]),
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(
    body,
    "\"message\":\"best_before_date is not a valid calendar date\"",
  )
}

pub fn create_stock_item_skir_handler_maps_best_before_date_test() {
  let handler =
    testsetup.build_handler_with_create_stock_item_ports(fn(_) {
      create_stock_item.Ports(
        does_product_exist: fn(_) { Ok(True) },
        create: fn(item) {
          let stock_item.StockItem(product_id: item_product_id, ..) = item
          let assert Ok(expected_product_id) =
            product_id.new(common.valid_product_id)

          assert item_product_id == expected_product_id
          Ok(Nil)
        },
      )
    })

  let request =
    common.json_request(http.Post, "/api/v1/stock_items")
    |> simulate.json_body(
      json.object([
        #("product_id", json.string(common.valid_product_id)),
        #("best_before_date", json.string("2027-01-01")),
      ]),
    )

  let response = handler(request)

  assert response.status == 201
}
