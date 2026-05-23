import application/commands/remove_stock_item
import application/shared/infrastructure_error
import common/product_id
import domain/stock_items/best_before_date
import driver/http/handler_helpers
import driver/http/stock_items/remove/response_mapper
import driver/http/wire_format
import gleam/json
import wisp

fn error_response(error: remove_stock_item.Error) -> wisp.Response {
  case error {
    remove_stock_item.StockItemNotFound ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("not_found")),
            #("message", json.string("stock item not found")),
          ]),
        ),
        404,
      )
    remove_stock_item.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      wisp.internal_server_error()
  }
}

pub fn handle(
  product_id_raw: String,
  best_before_date_raw: String,
  request: wisp.Request,
  port: remove_stock_item.RemovePort,
) -> wisp.Response {
  use item_product_id <-
    product_id.new(product_id_raw)
    |> handler_helpers.on_error_value(handler_helpers.bad_request(
      "product id is invalid",
    ))

  use item_best_before_date <-
    best_before_date.new(best_before_date_raw)
    |> handler_helpers.on_error(fn(error) {
      case error {
        best_before_date.Empty ->
          handler_helpers.bad_request("best_before_date is required")
        best_before_date.InvalidFormat ->
          handler_helpers.bad_request(
            "best_before_date must use format YYYY-MM-DD",
          )
        best_before_date.InvalidDate ->
          handler_helpers.bad_request(
            "best_before_date is not a valid calendar date",
          )
      }
    })

  let command =
    remove_stock_item.Command(
      product_id: item_product_id,
      best_before_date: item_best_before_date,
    )

  case remove_stock_item.execute(command, port) {
    Ok(payload) -> {
      let format = wire_format.from_accept_header(request)
      wisp.response(200)
      |> response_mapper.encode_response(payload, format)
    }
    Error(error) -> error_response(error)
  }
}
