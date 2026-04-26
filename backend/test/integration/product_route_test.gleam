import application/page_limit
import application/page_offset
import application/ports/product_repository
import domain/basics/uuid
import domain/product
import driver/http/products/handler
import driver/http/router
import gleam/http
import gleam/list
import gleam/option.{None}
import gleam/string
import wisp
import wisp/simulate

fn product_id(value: String) -> product.Id {
  product.ProductId(uuid.new_exn(value))
}

fn make_product(value: String, name: String) -> product.T {
  product.Product(id: product_id(value), name: name, parent_product_id: None)
}

fn list_products_mock(
  params: product_repository.ListParams,
) -> Result(product_repository.ListResult, Nil) {
  let product_repository.ListParams(offset:, limit:) = params

  let product_1 =
    make_product("018f4e1a-0000-7000-8000-000000000001", "Espresso")
  let product_2 = make_product("018f4e1a-0000-7000-8000-000000000002", "Latte")
  let product_3 =
    make_product("018f4e1a-0000-7000-8000-000000000003", "Cappuccino")

  let all = [product_1, product_2, product_3]
  let items =
    all
    |> list.drop(page_offset.value(offset))
    |> list.take(page_limit.value(limit))

  Ok(product_repository.ListResult(items: items, total: 3))
}

fn mock_repository() -> product_repository.T {
  product_repository.T(list: list_products_mock)
}

fn app_handler() -> fn(wisp.Request) -> wisp.Response {
  let repo = mock_repository()
  let routes =
    router.Routes(products: fn(request) { handler.handle(request, repo) })

  fn(request) { router.handle_request(request, routes) }
}

pub fn products_route_returns_paginated_json_test() {
  let request = simulate.request(http.Get, "/api/v1/products?limit=2")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"total\":3")
  assert string.contains(body, "\"limit\":2")
  assert string.contains(body, "\"offset\":0")
  assert string.contains(body, "\"name\":\"Espresso\"")
}

pub fn products_route_uses_offset_param_test() {
  let request = simulate.request(http.Get, "/api/v1/products?offset=1&limit=1")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"total\":3")
  assert string.contains(body, "\"offset\":1")
  assert string.contains(body, "\"limit\":1")
  assert string.contains(body, "\"name\":\"Latte\"")
}

pub fn products_route_rejects_invalid_limit_test() {
  let request = simulate.request(http.Get, "/api/v1/products?limit=abc")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
  assert string.contains(body, "\"message\":\"limit must be an integer\"")
}

pub fn products_route_rejects_out_of_range_limit_test() {
  let request = simulate.request(http.Get, "/api/v1/products?limit=999")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
  assert string.contains(
    body,
    "\"message\":\"limit must be between 1 and 100\"",
  )
}

pub fn products_route_rejects_negative_offset_test() {
  let request = simulate.request(http.Get, "/api/v1/products?offset=-1")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
  assert string.contains(
    body,
    "\"message\":\"offset must be greater than or equal to 0\"",
  )
}

pub fn products_route_rejects_non_get_methods_test() {
  let request = simulate.request(http.Post, "/api/v1/products")

  let response = app_handler()(request)

  assert response.status == 405
}

pub fn unknown_route_returns_not_found_test() {
  let request = simulate.request(http.Get, "/api/v1/unknown")

  let response = app_handler()(request)

  assert response.status == 404
}
