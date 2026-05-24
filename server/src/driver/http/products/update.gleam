import application/commands/products/update/command as update_product_command
import application/commands/products/update/ports
import application/shared/infrastructure_error
import driver/http/handler_helpers
import driver/shared/parse_error
import driver/shared/products/update/request_parser
import driver/skirout/products/commands
import gleam/http
import gleam/result
import skir_client/serializer
import wisp

fn command_error_response(
  error: update_product_command.Error,
) -> wisp.Response {
  case error {
    update_product_command.ProductNotFound -> wisp.not_found()
    update_product_command.ParentIdDoesntExist ->
      wisp.bad_request("parent product does not exist")
    update_product_command.BarcodeToRemoveNotAssignedToProduct ->
      wisp.bad_request("barcode to remove is not assigned to product")
    update_product_command.BarcodeAssignedToAnotherProduct ->
      wisp.bad_request("barcode is already assigned to another product")
    update_product_command.InfrastructureError(
      infrastructure_error.DatabaseFailure,
    ) -> wisp.internal_server_error()
  }
}

pub fn handle(
  id id: String,
  request request: wisp.Request,
  ports ports: ports.T,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Patch)
  use body <- wisp.require_string_body(request)

  // Parse payload
  use payload <-
    body
    |> serializer.from_json_code(
      commands.update_product_request_serializer(),
      _,
    )
    |> result.map(fn(payload) { commands.UpdateProductRequest(..payload, id:) })
    |> handler_helpers.on_error(wisp.bad_request)

  // Build command
  use command <-
    request_parser.parse(payload)
    |> handler_helpers.on_error(fn(e) {
      case e {
        parse_error.ParseError(message) -> wisp.bad_request(message)
      }
    })

  update_product_command.handle(command, ports)
  |> handler_helpers.on_error(command_error_response)

  wisp.no_content()
}
