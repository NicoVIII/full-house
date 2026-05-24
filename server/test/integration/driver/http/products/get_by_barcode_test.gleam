import gleam/http
import gleam/string
import integration/driver/http/products/fixtures
import integration/driver/http/testsetup
import wisp/simulate

pub fn get_by_barcode_existing_barcode_returns_200_test() {
  let handler =
    testsetup.build_handler_with_get_product_by_barcode_port(
      fixtures.get_product_by_barcode_port,
    )

  let request =
    fixtures.request(http.Get, "/api/v1/products/by-barcode/4006381333931")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 200
  assert string.contains(body, "\"name\": \"Espresso\"")
  assert string.contains(body, "\"barcodes\":")
  assert string.contains(body, "\"4006381333931\"")
}

pub fn get_by_barcode_unknown_barcode_returns_404_test() {
  let handler =
    testsetup.build_handler_with_get_product_by_barcode_port(
      fixtures.get_product_by_barcode_port,
    )

  let request =
    fixtures.request(http.Get, "/api/v1/products/by-barcode/9999999999999")

  let response = handler(request)
  let body = simulate.read_body(response)

  assert response.status == 404
  assert string.contains(body, "\"message\":\"product not found\"")
}
