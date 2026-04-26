import application/page_limit
import application/page_offset
import application/ports/products/create as create_product_port
import application/ports/products/list as list_product_port
import domain/basics/uuid
import domain/product
import domain/product_name
import driver/http/products/handler
import driver/http/router
import gleam/http
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import wisp
import wisp/simulate

fn product_id(value: String) -> product.Id {
  product.ProductId(uuid.new_exn(value))
}

fn make_product(value: String, name: String) -> product.T {
  product.Product(
    id: product_id(value),
    name: product_name.new_exn(name),
    parent_product_id: None,
  )
}

fn list_products_mock(
  params: list_product_port.Params,
) -> Result(list_product_port.ListResult, list_product_port.Error) {
  let list_product_port.Params(offset:, limit:) = params

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

  Ok(list_product_port.ListResult(items: items, total: 3))
}

fn create_product_mock(
  new_product: product.T,
) -> Result(Nil, create_product_port.Error) {
  let product.Product(parent_product_id:, ..) = new_product

  case parent_product_id {
    Some(_) -> Error(create_product_port.ParentProductNotFound)
    None -> Ok(Nil)
  }
}

fn list_repository() -> list_product_port.T {
  list_product_port.T(list: list_products_mock)
}

fn create_repository() -> create_product_port.T {
  create_product_port.T(create: create_product_mock)
}

fn app_handler() -> fn(wisp.Request) -> wisp.Response {
  let list_repo = list_repository()
  let create_repo = create_repository()
  let routes =
    router.Routes(
      products: fn(request) { handler.handle(request, list_repo, create_repo) },
      stock: fn(_) { wisp.not_found() },
    )

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

pub fn products_route_creates_product_test() {
  let request =
    simulate.request(http.Post, "/api/v1/products")
    |> simulate.json_body(json.object([#("name", json.string("Pour Over"))]))

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 201
  assert string.contains(body, "\"name\":\"Pour Over\"")
  assert string.contains(body, "\"id\":")
}

pub fn products_route_rejects_empty_name_on_create_test() {
  let request =
    simulate.request(http.Post, "/api/v1/products")
    |> simulate.json_body(json.object([#("name", json.string("   "))]))

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"message\":\"name must not be empty\"")
}

pub fn products_route_rejects_invalid_parent_product_id_on_create_test() {
  let request =
    simulate.request(http.Post, "/api/v1/products")
    |> simulate.json_body(
      json.object([
        #("name", json.string("Flat White")),
        #("parent_product_id", json.string("not-a-uuid")),
      ]),
    )

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(
    body,
    "\"message\":\"parent_product_id must be a valid UUID\"",
  )
}

pub fn products_route_returns_error_for_missing_parent_product_test() {
  let request =
    simulate.request(http.Post, "/api/v1/products")
    |> simulate.json_body(
      json.object([
        #("name", json.string("Flat White")),
        #(
          "parent_product_id",
          json.string("018f4e1a-0000-7000-8000-000000000099"),
        ),
      ]),
    )

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(
    body,
    "\"message\":\"parent_product_id does not reference an existing product\"",
  )
}

pub fn products_route_rejects_unsupported_methods_test() {
  let request = simulate.request(http.Put, "/api/v1/products")

  let response = app_handler()(request)

  assert response.status == 405
}

pub fn unknown_route_returns_not_found_test() {
  let request = simulate.request(http.Get, "/api/v1/unknown")

  let response = app_handler()(request)

  assert response.status == 404
}
