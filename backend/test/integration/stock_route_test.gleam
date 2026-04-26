import driver/http/router
import driver/http/stock/handler
import gleam/http
import gleam/string
import infrastructure/stock_repository/mock_stock_repository
import wisp
import wisp/simulate

fn app_handler() -> fn(wisp.Request) -> wisp.Response {
  let repo = mock_stock_repository.new()
  let routes =
    router.Routes(products: fn(_) { wisp.not_found() }, stock: fn(request) {
      handler.handle(request, repo)
    })

  fn(request) { router.handle_request(request, routes) }
}

pub fn stock_route_returns_paginated_json_test() {
  let request = simulate.request(http.Get, "/api/v1/stock?limit=2")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"total\":5")
  assert string.contains(body, "\"limit\":2")
  assert string.contains(body, "\"offset\":0")
  assert string.contains(body, "\"product_name\":\"Espresso\"")
  assert string.contains(body, "\"quantity\":4")
}

pub fn stock_route_uses_offset_param_test() {
  let request = simulate.request(http.Get, "/api/v1/stock?offset=1&limit=1")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"total\":5")
  assert string.contains(body, "\"offset\":1")
  assert string.contains(body, "\"limit\":1")
  assert string.contains(body, "\"product_name\":\"Cappuccino\"")
  assert string.contains(body, "\"quantity\":2")
}

pub fn stock_route_rejects_invalid_limit_test() {
  let request = simulate.request(http.Get, "/api/v1/stock?limit=abc")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
  assert string.contains(body, "\"message\":\"limit must be an integer\"")
}

pub fn stock_route_rejects_out_of_range_limit_test() {
  let request = simulate.request(http.Get, "/api/v1/stock?limit=999")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
  assert string.contains(
    body,
    "\"message\":\"limit must be between 1 and 100\"",
  )
}

pub fn stock_route_rejects_negative_offset_test() {
  let request = simulate.request(http.Get, "/api/v1/stock?offset=-1")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
  assert string.contains(
    body,
    "\"message\":\"offset must be greater than or equal to 0\"",
  )
}

pub fn stock_route_rejects_non_get_methods_test() {
  let request = simulate.request(http.Post, "/api/v1/stock")

  let response = app_handler()(request)

  assert response.status == 405
}
