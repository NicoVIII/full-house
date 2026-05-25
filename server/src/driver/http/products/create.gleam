import application/commands/products/create/command
import application/commands/products/create/ports
import application/shared/infrastructure_error
import driver/http/handler_helpers
import driver/shared/parse_error
import driver/shared/products/create/request_parser
import driver/skirout/products/commands
import gleam/http
import skir_client/serializer
import wisp

fn create_error_response(error: command.Error) -> wisp.Response {
  case error {
    command.IdAlreadyExists -> handler_helpers.conflict("id already exists")
    command.ParentDoesNotExist ->
      wisp.bad_request(
        "parent_product_id does not reference an existing product",
      )
    command.BarcodeAssignedToAnotherProduct ->
      handler_helpers.conflict("barcode is already assigned to another product")
    command.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      wisp.internal_server_error()
  }
}

pub fn handle(
  request request: wisp.Request,
  ports ports: ports.T,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Post)
  use body <- wisp.require_string_body(request)

  // Parse payload
  use payload <-
    serializer.from_json_code(
      commands.create_product_request_serializer(),
      body,
    )
    |> handler_helpers.on_error(wisp.bad_request)

  // Build command
  use command <-
    request_parser.parse(payload)
    |> handler_helpers.on_error(fn(e) {
      case e {
        parse_error.ParseError(message) -> wisp.bad_request(message)
      }
    })

  // Execute command
  use Nil <-
    command.handle(command, ports)
    |> handler_helpers.on_error(create_error_response)

  // Prepare success response
  wisp.created()
}
