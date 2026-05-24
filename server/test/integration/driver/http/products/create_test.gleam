import application/commands/create_product
import gleam/http
import gleam/json
import gleam/string
import integration/driver/http/products/fixtures
import integration/driver/http/testsetup
import wisp
import wisp/simulate

fn prepare_handler() -> fn(wisp.Request) -> wisp.Response {
  testsetup.build_handler_with_create_product_ports(fn(_ports) {
    create_product.Ports(
      does_product_exist: fixtures.does_product_exist_port,
      create: fixtures.create_product_port,
    )
  })
}

pub fn create_product_returns_201_test() {
  let handler = prepare_handler()

  let request =
    fixtures.request(http.Post, "/api/v1/products")
    |> simulate.json_body(json.object([#("name", json.string("Pour Over"))]))

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 201
  assert string.contains(body, "\"name\": \"Pour Over\"")
  assert string.contains(body, "\"id\":")
}

pub fn create_product_rejects_empty_name_test() {
  let handler = prepare_handler()

  let request =
    fixtures.request(http.Post, "/api/v1/products")
    |> simulate.json_body(json.object([#("name", json.string("   "))]))

  let response = handler(request)

  assert response.status == 400
}

pub fn create_product_rejects_name_with_newline_test() {
  let handler = prepare_handler()

  let request =
    fixtures.request(http.Post, "/api/v1/products")
    |> simulate.json_body(json.object([#("name", json.string("Flat\nWhite"))]))

  let response = handler(request)

  assert response.status == 400
}

pub fn create_product_rejects_invalid_parent_product_id_test() {
  let handler = prepare_handler()

  let request =
    fixtures.request(http.Post, "/api/v1/products")
    |> simulate.json_body(
      json.object([
        #("name", json.string("Flat White")),
        #("parent_product_id", json.string("not-a-uuid")),
      ]),
    )

  let response = handler(request)

  assert response.status == 400
}

pub fn create_product_rejects_missing_parent_product_test() {
  let handler = prepare_handler()

  let request =
    fixtures.request(http.Post, "/api/v1/products")
    |> simulate.json_body(
      json.object([
        #("name", json.string("Flat White")),
        #("parent_product_id", json.string(fixtures.missing_product_id)),
      ]),
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 400
  assert string.contains(
    body,
    "\"message\":\"parent_product_id does not reference an existing product\"",
  )
}
