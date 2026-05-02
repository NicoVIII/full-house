import application/commands/create_product
import application/commands/delete_product
import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/product_query_model
import application/queries/get_product
import application/queries/list_products
import application/queries/list_stock_items
import application/shared/infrastructure_error
import common/product_id
import composition
import domain/products/deletable_product_id
import full_house
import gleam/http
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import wisp
import wisp/simulate

fn make_model(
  id: String,
  name: String,
  parent: option.Option(String),
  children: List(String),
) -> product_query_model.T {
  product_query_model.ProductQueryModel(
    id: id,
    name: name,
    parent_product_id: parent,
    children_ids: children,
  )
}

fn all_products() -> List(product_query_model.T) {
  [
    make_model("018f4e1a-0000-7000-8000-000000000001", "Espresso", None, []),
    make_model("018f4e1a-0000-7000-8000-000000000002", "Latte", None, [
      "018f4e1a-0000-7000-8000-000000000003",
      "018f4e1a-0000-7000-8000-000000000004",
    ]),
    make_model(
      "018f4e1a-0000-7000-8000-000000000003",
      "Cappuccino",
      Some("018f4e1a-0000-7000-8000-000000000002"),
      [],
    ),
    make_model(
      "018f4e1a-0000-7000-8000-000000000004",
      "Mocha Latte",
      Some("018f4e1a-0000-7000-8000-000000000002"),
      [],
    ),
  ]
}

fn list_products_mock(
  limit: page_limit.T,
  offset: page_offset.T,
) -> Result(list_products.ListProductsResult, infrastructure_error.T) {
  let all = all_products()
  let items =
    all
    |> list.drop(page_offset.value(offset))
    |> list.take(page_limit.value(limit))

  Ok(list_products.ListProductsResult(
    data: items,
    total: list.length(all),
    limit: limit,
    offset: offset,
  ))
}

fn get_product_mock(
  id: product_id.T,
) -> Result(product_query_model.T, get_product.GetProductError) {
  case list.find(all_products(), fn(p) { p.id == product_id.value(id) }) {
    Ok(found) -> Ok(found)
    Error(_) -> Error(get_product.ProductNotFound)
  }
}

fn does_product_exist_mock(
  id: product_id.T,
) -> Result(Bool, infrastructure_error.T) {
  let id_str = product_id.value(id)
  Ok(!string.ends_with(id_str, "99"))
}

fn create_product_mock(_new_product: _) -> Result(Nil, infrastructure_error.T) {
  Ok(Nil)
}

fn get_deletion_properties_mock(
  id: product_id.T,
) -> Result(delete_product.DeletionProperties, infrastructure_error.T) {
  let id_str = product_id.value(id)
  case
    string.ends_with(id_str, "999"),
    string.ends_with(id_str, "001"),
    string.ends_with(id_str, "003")
  {
    _, True, _ ->
      Ok(delete_product.DeletionProperties(
        has_children: False,
        has_stock_items: True,
      ))
    _, _, True ->
      Ok(delete_product.DeletionProperties(
        has_children: True,
        has_stock_items: False,
      ))
    _, _, _ ->
      Ok(delete_product.DeletionProperties(
        has_children: False,
        has_stock_items: False,
      ))
  }
}

fn delete_product_mock(
  _id: deletable_product_id.T,
) -> Result(Nil, infrastructure_error.T) {
  Ok(Nil)
}

fn list_stock_mock(
  _limit: page_limit.T,
  _offset: page_offset.T,
) -> Result(list_stock_items.ListStockItemsResult, infrastructure_error.T) {
  Ok(list_stock_items.ListStockItemsResult(
    data: [],
    total: 0,
    limit: page_limit.default(),
    offset: page_offset.default(),
  ))
}

fn mock_app_context() -> composition.AppContext {
  composition.AppContext(
    get_product_port: get_product_mock,
    list_products_port: list_products_mock,
    create_product_ports: create_product.Ports(
      does_product_exist: does_product_exist_mock,
      create: create_product_mock,
    ),
    delete_product_ports: delete_product.Ports(
      get_deletion_properties: get_deletion_properties_mock,
      delete: delete_product_mock,
      load_product: fn(_id) { Error(delete_product.LoadProductNotFound) },
    ),
    list_stock_items_port: list_stock_mock,
  )
}

fn app_handler() -> fn(wisp.Request) -> wisp.Response {
  let context = mock_app_context()
  full_house.build_handler(context)
}

pub fn product_detail_route_returns_product_json_test() {
  let request =
    simulate.request(
      http.Get,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000003",
    )

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"name\":\"Cappuccino\"")
  assert string.contains(
    body,
    "\"parent_product_id\":\"018f4e1a-0000-7000-8000-000000000002\"",
  )
}

pub fn product_detail_route_rejects_invalid_product_id_test() {
  let request = simulate.request(http.Get, "/api/v1/products/not-a-uuid")

  let response = app_handler()(request)

  assert response.status == 400
}

pub fn product_detail_route_returns_not_found_test() {
  let request =
    simulate.request(
      http.Get,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000099",
    )

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 404
  assert string.contains(body, "\"message\":\"product not found\"")
}

pub fn products_route_returns_paginated_json_test() {
  let request = simulate.request(http.Get, "/api/v1/products?limit=2")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"total\":4")
  assert string.contains(body, "\"limit\":2")
  assert string.contains(body, "\"offset\":0")
  assert string.contains(body, "\"name\":\"Espresso\"")
}

pub fn products_route_uses_offset_param_test() {
  let request = simulate.request(http.Get, "/api/v1/products?offset=1&limit=1")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"total\":4")
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

pub fn products_route_rejects_name_with_newline_on_create_test() {
  let request =
    simulate.request(http.Post, "/api/v1/products")
    |> simulate.json_body(json.object([#("name", json.string("Flat\nWhite"))]))

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(
    body,
    "\"message\":\"name must not contain tabs or newlines\"",
  )
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
