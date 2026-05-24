import application/commands/stock_items/create/command as create_stock_item_command
import application/commands/stock_items/create/ports
import application/shared/infrastructure_error
import driver/http/handler_helpers
import driver/shared/parse_error
import driver/shared/stock_items/create/request_parser
import driver/skirout/stock_items/commands
import gleam/http
import skir_client/serializer
import wisp

fn create_error_response(
  error: create_stock_item_command.Error,
) -> wisp.Response {
  case error {
    create_stock_item_command.ProductDoesNotExist ->
      wisp.bad_request("product_id does not reference an existing product")
    create_stock_item_command.InfrastructureError(
      infrastructure_error.DatabaseFailure,
    ) -> wisp.internal_server_error()
  }
}

pub fn handle(
  request request: wisp.Request,
  ports ports: ports.T,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Post)
  use body <- wisp.require_string_body(request)
  use payload <-
    serializer.from_json_code(
      commands.create_stock_item_request_serializer(),
      body,
    )
    |> handler_helpers.on_error(wisp.bad_request)

  use command <-
    request_parser.parse(payload)
    |> handler_helpers.on_error(fn(e) {
      case e {
        parse_error.ParseError(message) -> wisp.bad_request(message)
      }
    })

  use Nil <-
    create_stock_item_command.handle(command, ports)
    |> handler_helpers.on_error(create_error_response)

  wisp.created()
}
