import application/queries/get_product_by_barcode
import application/shared/infrastructure_error
import domain/products/barcodes/barcode
import driver/http/handler_helpers
import driver/http/products/skir
import driver/http/wire_format
import gleam/json
import gleam/list
import wisp

fn error_response(
  error: get_product_by_barcode.GetProductByBarcodeError,
) -> wisp.Response {
  case error {
    get_product_by_barcode.ProductNotFound ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("not_found")),
            #("message", json.string("product not found")),
          ]),
        ),
        404,
      )
    get_product_by_barcode.InfrastructureError(
      infrastructure_error.DatabaseFailure,
    ) -> wisp.internal_server_error()
  }
}

pub fn handle(
  request: wisp.Request,
  port: get_product_by_barcode.GetProductByBarcodePort,
) -> wisp.Response {
  use barcode_raw <-
    list.key_find(wisp.get_query(request), "barcode")
    |> handler_helpers.on_error_value(wisp.bad_request(
      "barcode query parameter is required",
    ))

  use product_barcode <-
    barcode.from_user_input(barcode_raw)
    |> handler_helpers.on_error_value(wisp.bad_request("barcode is invalid"))

  case get_product_by_barcode.execute(product_barcode, port) {
    Ok(found_product) -> {
      let format = wire_format.from_accept_header(request)
      wisp.response(200)
      |> skir.encode_product(found_product, format)
    }
    Error(error) -> error_response(error)
  }
}
