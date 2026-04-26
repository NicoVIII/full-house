import application/page_limit
import application/page_offset
import application/ports/stock_repository
import domain/basics/uuid
import domain/product
import driver/http/router
import driver/http/stock/handler
import gleam/http
import gleam/list
import gleam/string
import wisp
import wisp/simulate

fn product_id(value: String) -> product.Id {
  product.ProductId(uuid.new_exn(value))
}

fn list_stock_mock(
  params: stock_repository.ListParams,
) -> Result(stock_repository.ListResult, Nil) {
  let stock_repository.ListParams(offset:, limit:) = params

  let all = [
    stock_repository.StockSummary(
      product_id: product_id("018f4e1a-0000-7000-8000-000000000001"),
      product_name: "Espresso",
      quantity: 4,
    ),
    stock_repository.StockSummary(
      product_id: product_id("018f4e1a-0000-7000-8000-000000000002"),
      product_name: "Cappuccino",
      quantity: 2,
    ),
    stock_repository.StockSummary(
      product_id: product_id("018f4e1a-0000-7000-8000-000000000003"),
      product_name: "Latte",
      quantity: 3,
    ),
    stock_repository.StockSummary(
      product_id: product_id("018f4e1a-0000-7000-8000-000000000007"),
      product_name: "Matcha",
      quantity: 5,
    ),
    stock_repository.StockSummary(
      product_id: product_id("018f4e1a-0000-7000-8000-000000000009"),
      product_name: "Oat Latte",
      quantity: 1,
    ),
  ]
  let items =
    all
    |> list.drop(page_offset.value(offset))
    |> list.take(page_limit.value(limit))

  Ok(stock_repository.ListResult(items: items, total: 5))
}

fn mock_repository() -> stock_repository.T {
  stock_repository.T(list: list_stock_mock)
}

fn app_handler() -> fn(wisp.Request) -> wisp.Response {
  let repo = mock_repository()
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
