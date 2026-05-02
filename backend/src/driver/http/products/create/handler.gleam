import application/commands/create_product
import application/shared/infrastructure_error
import driver/http/handler_helpers
import driver/http/products/create/request_mapper
import driver/http/products/create/response_mapper
import gleam/http
import gleam/json
import wisp

fn create_error_response(error: create_product.Error) -> wisp.Response {
  case error {
    create_product.ParentDoesNotExist ->
      handler_helpers.bad_request(
        "parent_product_id does not reference an existing product",
      )
    create_product.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      wisp.internal_server_error()
  }
}

pub fn handle(
  request: wisp.Request,
  ports: create_product.Ports,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Post)
  use payload <- wisp.require_json(request)
  use #(name, parent_product_id) <-
    request_mapper.map_payload(payload)
    |> handler_helpers.on_error(handler_helpers.bad_request)

  let command =
    create_product.Command(name: name, parent_product_id: parent_product_id)

  use result <-
    create_product.execute(command, ports)
    |> handler_helpers.on_error(create_error_response)

  response_mapper.map_product_without_children(result)
  |> json.to_string
  |> wisp.json_response(201)
}
