import composition
import gleam/http
import gleam/json
import gleam/string
import integration/driver/http/products/fixtures
import integration/driver/http/testsetup
import wisp
import wisp/simulate

fn prepare_handler() -> fn(wisp.Request) -> wisp.Response {
  testsetup.build_handler(fn(ctx) {
    composition.AppContext(
      ..ctx,
      update_product_barcodes_port: fixtures.update_product_barcodes_port,
      get_product_port: fixtures.get_product_port,
    )
  })
}

pub fn update_barcodes_existing_product_returns_200_test() {
  let handler = prepare_handler()

  let request =
    fixtures.request(
      http.Patch,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000001",
    )
    |> simulate.json_body(
      json.object([
        #("add_barcodes", json.array(["0123456789012"], of: json.string)),
        #("remove_barcodes", json.array(["4006381333931"], of: json.string)),
      ]),
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(
    body,
    "\"id\": \"018f4e1a-0000-7000-8000-000000000001\"",
  )
}

pub fn update_barcodes_missing_product_returns_404_test() {
  let handler = prepare_handler()

  let request =
    fixtures.request(
      http.Patch,
      "/api/v1/products/018f4e1a-0000-7000-8000-000000000099",
    )
    |> simulate.json_body(
      json.object([
        #("add_barcodes", json.array([], of: json.string)),
        #("remove_barcodes", json.array(["4006381333931"], of: json.string)),
      ]),
    )

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 404
  assert string.contains(body, "\"message\":\"product not found\"")
}
