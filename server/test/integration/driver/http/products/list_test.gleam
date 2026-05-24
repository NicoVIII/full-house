import gleam/http
import gleam/string
import integration/driver/http/products/fixtures
import integration/driver/http/testsetup
import wisp/simulate

pub fn list_products_returns_paginated_json_test() {
  let handler =
    testsetup.build_handler_with_list_products_port(fixtures.list_products_port)

  let request = fixtures.request(http.Get, "/api/v1/products?limit=2")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"total\": 4")
  assert string.contains(body, "\"limit\": 2")
  assert string.contains(body, "\"name\": \"Espresso\"")
}

pub fn list_products_uses_offset_param_test() {
  let handler =
    testsetup.build_handler_with_list_products_port(fixtures.list_products_port)

  let request = fixtures.request(http.Get, "/api/v1/products?offset=1&limit=1")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"total\": 4")
  assert string.contains(body, "\"offset\": 1")
  assert string.contains(body, "\"limit\": 1")
  assert string.contains(body, "\"name\": \"Latte\"")
}

pub fn list_products_rejects_invalid_limit_test() {
  let handler =
    testsetup.build_handler_with_list_products_port(fixtures.list_products_port)

  let request = fixtures.request(http.Get, "/api/v1/products?limit=abc")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
}

pub fn list_products_rejects_out_of_range_limit_test() {
  let handler =
    testsetup.build_handler_with_list_products_port(fixtures.list_products_port)

  let request = fixtures.request(http.Get, "/api/v1/products?limit=999")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
}

pub fn list_products_rejects_negative_offset_test() {
  let handler =
    testsetup.build_handler_with_list_products_port(fixtures.list_products_port)

  let request = fixtures.request(http.Get, "/api/v1/products?offset=-1")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
}

pub fn list_products_rejects_unsupported_methods_test() {
  let handler =
    testsetup.build_handler_with_list_products_port(fixtures.list_products_port)

  let request = fixtures.request(http.Put, "/api/v1/products")

  let response = handler(request)

  assert response.status == 405
}

pub fn unknown_route_returns_not_found_test() {
  let handler =
    testsetup.build_handler_with_list_products_port(fixtures.list_products_port)

  let request = fixtures.request(http.Get, "/api/v1/unknown")

  let response = handler(request)

  assert response.status == 404
}
