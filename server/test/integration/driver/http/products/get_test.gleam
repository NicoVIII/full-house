import gleam/http
import gleam/string
import integration/driver/http/products/fixtures
import integration/driver/http/testsetup
import wisp/simulate

pub fn get_product_returns_product_json_test() {
  let handler =
    testsetup.build_handler_with_get_product_port(fixtures.get_product_port)

  let request =
    fixtures.request(
      http.Get,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000003",
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"name\": \"Cappuccino\"")
  assert string.contains(
    body,
    "\"parent_product_id\": \"018f4e1a-0000-7000-8000-000000000002\"",
  )
}

pub fn get_product_rejects_invalid_product_id_test() {
  let handler =
    testsetup.build_handler_with_get_product_port(fixtures.get_product_port)

  let request = fixtures.request(http.Get, "/api/v1/products/not-a-uuid")

  let response = handler(request)

  assert response.status == 400
}

pub fn get_product_returns_not_found_test() {
  let handler =
    testsetup.build_handler_with_get_product_port(fixtures.get_product_port)

  let request =
    fixtures.request(
      http.Get,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000099",
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 404
  assert string.contains(body, "\"message\":\"product not found\"")
}
