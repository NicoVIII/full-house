import application/commands/create_product
import application/shared/infrastructure_error
import driver/http/handler_helpers
import driver/http/products/create/request_mapper
import driver/http/products/create/response_mapper
import driver/http/wire_format
import gleam/http
import wisp

fn create_error_response(error: create_product.Error) -> wisp.Response {
  case error {
    create_product.InvalidName -> handler_helpers.bad_request("name invalid")
    create_product.InvalidParentId ->
      handler_helpers.bad_request("parent_product_id invalid")
    create_product.ParentDoesNotExist ->
      handler_helpers.bad_request(
        "parent_product_id does not reference an existing product",
      )
    create_product.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      wisp.internal_server_error()
  }
}

pub fn handle(
  request request: wisp.Request,
  ports ports: create_product.Ports,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Post)
  use body <- wisp.require_string_body(request)

  use #(name, parent_product_id) <-
    request_mapper.map_payload(body)
    |> handler_helpers.on_error(fn(error) {
      request_mapper.error_to_string(error) |> handler_helpers.bad_request
    })

  let command = create_product.Command(name:, parent_product_id:)

  use result <-
    create_product.execute(command, ports)
    |> handler_helpers.on_error(create_error_response)

  let format = wire_format.from_accept_header(request)
  wisp.response(201)
  |> response_mapper.encode_product_without_children(result, format)
}
