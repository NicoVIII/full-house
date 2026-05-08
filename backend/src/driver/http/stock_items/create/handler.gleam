import application/commands/create_stock_item
import application/shared/infrastructure_error
import driver/http/handler_helpers
import driver/http/stock_items/create/request_mapper
import driver/http/stock_items/create/response_mapper
import gleam/http
import gleam/json
import wisp

fn create_error_response(error: create_stock_item.Error) -> wisp.Response {
  case error {
    create_stock_item.ProductDoesNotExist ->
      handler_helpers.bad_request(
        "product_id does not reference an existing product",
      )
    create_stock_item.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      wisp.internal_server_error()
  }
}

pub fn handle(
  request request: wisp.Request,
  ports ports: create_stock_item.Ports,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Post)
  use payload <- wisp.require_json(request)
  use product_id <-
    request_mapper.map_payload(payload)
    |> handler_helpers.on_error(fn(error) {
      request_mapper.error_to_string(error) |> handler_helpers.bad_request
    })

  let command = create_stock_item.Command(product_id:)

  use result <-
    create_stock_item.execute(command, ports)
    |> handler_helpers.on_error(create_error_response)

  response_mapper.map_stock_item(result)
  |> json.to_string
  |> wisp.json_response(201)
}
