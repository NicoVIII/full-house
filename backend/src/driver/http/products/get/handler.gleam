import application/queries/get_product
import application/shared/infrastructure_error
import common/product_id
import driver/http/handler_helpers
import driver/http/products/product_json
import gleam/json
import wisp

fn error_response(error: get_product.GetProductError) -> wisp.Response {
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
  port port: get_product.GetProductPort,
) -> wisp.Response {
  use id <-
    product_id.new(id_raw)
    |> handler_helpers.on_error_value(handler_helpers.bad_request(
      "product id is invalid",
    ))

  case get_product.execute(id, port) {
    Ok(found_product) ->
      wisp.json_response(
        product_json.map_product_query_model(found_product) |> json.to_string,
        200,
      )
    Error(error) -> error_response(error)
  }
}
