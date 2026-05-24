import application/commands/stock_items/delete/command as delete_stock_item_command
import application/commands/stock_items/delete/ports
import application/shared/infrastructure_error
import driver/http/handler_helpers
import driver/shared/stock_items/delete/request_parser
import driver/skirout/stock_items/commands
import gleam/http
import gleam/json
import wisp

fn error_response(error: delete_stock_item_command.Error) -> wisp.Response {
  case error {
    delete_stock_item_command.StockItemNotFound ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("not_found")),
            #("message", json.string("stock item not found")),
          ]),
        ),
        404,
      )
    delete_stock_item_command.InfrastructureError(
      infrastructure_error.DatabaseFailure,
    ) -> wisp.internal_server_error()
  }
}

pub fn handle(
  product_id: String,
  best_before_date: String,
  request: wisp.Request,
  port: ports.Delete,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Delete)

  use command <-
    request_parser.parse(commands.delete_stock_item_request_new(
      product_id,
      best_before_date,
    ))
    |> handler_helpers.on_error(fn(parse_error) {
      wisp.bad_request(parse_error.message)
    })

  use Nil <-
    delete_stock_item_command.handle(command, port)
    |> handler_helpers.on_error(error_response)

  wisp.no_content()
}
