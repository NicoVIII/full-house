import application/page_limit
import application/page_offset
import application/ports/products/create as create_product_port
import application/ports/products/delete as delete_product_port
import application/ports/products/deletion_references as deletion_references_port
import application/ports/products/list as list_product_port
import application/ports/products/validate_parent_product as validate_parent_product_port
import domain/basics/uuid
import domain/products/creation/validated_parent_id as validated_parent_product_id
import domain/products/deletion/references as product_deletion_references
import domain/products/product
import domain/products/product_name
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

fn delete_product_mock(
  product_id: product.Id,
) -> Result(Nil, delete_product_port.Error) {
  let product.ProductId(uid) = product_id
  let id_str = uuid.value(uid)

  // Mock: product with ID ending in 999 doesn't exist
  case string.ends_with(id_str, "999") {
    True -> Error(delete_product_port.ProductNotFound)
    False -> Ok(Nil)
  }
}

fn delete_repository() -> delete_product_port.T {
  delete_product_port.T(delete: delete_product_mock)
}

fn load_deletion_references_mock(
  product_id: product.Id,
) -> Result(product_deletion_references.T, deletion_references_port.Error) {
  let product.ProductId(uid) = product_id
  let id_str = uuid.value(uid)

  case string.ends_with(id_str, "001"), string.ends_with(id_str, "003") {
    True, _ -> Ok(product_deletion_references.new_exn(5, 0))
    False, True -> Ok(product_deletion_references.new_exn(0, 2))
    False, False -> Ok(product_deletion_references.new_exn(0, 0))
  }
}

fn deletion_references_repository() -> deletion_references_port.T {
  deletion_references_port.T(load: load_deletion_references_mock)
}

fn validate_parent_product_mock(
  parent_id: option.Option(product.Id),
) -> Result(
  option.Option(validated_parent_product_id.T),
  validate_parent_product_port.Error,
) {
  case parent_id {
    option.None -> Ok(option.None)
    option.Some(product.ProductId(uid)) -> {
      let id_str = uuid.value(uid)
      // Mock: IDs ending in 99 don't exist; everything else does
      case string.ends_with(id_str, "99") {
        True -> Error(validate_parent_product_port.ParentProductNotFound)
        False ->
          Ok(
            option.Some(validated_parent_product_id.new(product.ProductId(uid))),
          )
      }
    }
  }
}

fn validate_parent_repository() -> validate_parent_product_port.T {
  validate_parent_product_port.T(validate: validate_parent_product_mock)
}

fn app_handler() -> fn(wisp.Request) -> wisp.Response {
  let list_repo = list_repository()
  let validate_parent_repo = validate_parent_repository()
  let create_repo = create_repository()
  let deletion_references_repo = deletion_references_repository()
  let delete_repo = delete_repository()
  let routes =
    router.Routes(
      products: fn(request) {
        handler.handle(
          request,
          list_repo,
          validate_parent_repo,
          create_repo,
          deletion_references_repo,
          delete_repo,
        )
      },
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

pub fn delete_product_returns_204_test() {
  let request =
    simulate.request(
      http.Delete,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000002",
    )

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 204
  assert body == ""
}

pub fn delete_product_with_invalid_uuid_returns_400_test() {
  let request = simulate.request(http.Delete, "/api/v1/products/not-a-uuid")

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(body, "\"error\":\"invalid_parameter\"")
  assert string.contains(
    body,
    "\"message\":\"product id must be a valid UUID\"",
  )
}

pub fn delete_product_not_found_returns_404_test() {
  let request =
    simulate.request(
      http.Delete,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000999",
    )

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 404
  assert string.contains(body, "\"error\":\"not_found\"")
  assert string.contains(body, "\"message\":\"product not found\"")
}

pub fn delete_product_with_stock_items_returns_409_test() {
  let request =
    simulate.request(
      http.Delete,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000001",
    )

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 409
  assert string.contains(body, "\"error\":\"conflict\"")
  assert string.contains(
    body,
    "\"message\":\"cannot delete product with existing stock items\"",
  )
}

pub fn delete_product_with_child_products_returns_409_test() {
  let request =
    simulate.request(
      http.Delete,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000003",
    )

  let response = app_handler()(request)
  let body = simulate.read_body(response)

  assert response.status == 409
  assert string.contains(body, "\"error\":\"conflict\"")
  assert string.contains(
    body,
    "\"message\":\"cannot delete product with existing child products\"",
  )
}
