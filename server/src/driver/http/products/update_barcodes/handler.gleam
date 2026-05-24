import application/commands/update_product_barcodes
import application/queries/get_product
import application/shared/infrastructure_error
import common/product_id
import driver/http/handler_helpers
import driver/http/products/skir
import driver/http/products/update_barcodes/request_mapper
import driver/http/wire_format
import gleam/http
import gleam/json
import wisp

fn command_error_response(
  error: update_product_barcodes.Error,
) -> wisp.Response {
  case error {
    update_product_barcodes.InvalidBarcode ->
      handler_helpers.bad_request("barcode value is invalid")
    update_product_barcodes.ProductNotFound ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("not_found")),
            #("message", json.string("product not found")),
          ]),
        ),
        404,
      )
    update_product_barcodes.BarcodeAssignedToAnotherProduct(
      conflicting_product_name,
    ) ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("conflict")),
            #(
              "message",
              json.string(
                "barcode is already assigned to product \""
                <> conflicting_product_name
                <> "\"",
              ),
            ),
          ]),
        ),
        409,
      )
    update_product_barcodes.InfrastructureError(
      infrastructure_error.DatabaseFailure,
    ) -> wisp.internal_server_error()
  }
}

fn query_error_response(error: get_product.GetProductError) -> wisp.Response {
  case error {
    get_product.ProductNotFound ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("not_found")),
            #("message", json.string("product not found")),
          ]),
        ),
        404,
      )
    get_product.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      wisp.internal_server_error()
  }
}

pub fn handle(
  id_raw id_raw: String,
  request request: wisp.Request,
  command_port command_port: update_product_barcodes.UpdateBarcodesPort,
  get_port get_port: get_product.GetProductPort,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Patch)

  use id <-
    product_id.new(id_raw)
    |> handler_helpers.on_error_value(handler_helpers.bad_request(
      "product id is invalid",
    ))

  use body <- wisp.require_string_body(request)

  use #(add_barcodes, remove_barcodes) <-
    request_mapper.map_payload(body)
    |> handler_helpers.on_error(fn(error) {
      request_mapper.error_to_string(error) |> handler_helpers.bad_request
    })

  let command =
    update_product_barcodes.Command(
      id: id,
      add_barcodes: add_barcodes,
      remove_barcodes: remove_barcodes,
    )

  use _ <-
    update_product_barcodes.execute(command, command_port)
    |> handler_helpers.on_error(command_error_response)

  use found_product <-
    get_product.execute(id, get_port)
    |> handler_helpers.on_error(query_error_response)

  let format = wire_format.from_accept_header(request)
  wisp.response(200)
  |> skir.encode_product(found_product, format)
}
