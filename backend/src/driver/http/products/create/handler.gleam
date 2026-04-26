import application/create_product
import application/ports/products/create as create_product_port
import driver/http/handler_helpers
import driver/http/products/create/request_mapper
import driver/http/products/create/response_mapper
import gleam/http
import wisp

fn create_error_response(error: create_product_port.Error) -> wisp.Response {
  case error {
    create_product_port.ParentProductNotFound ->
      handler_helpers.bad_request(
        "parent_product_id does not reference an existing product",
      )
    _ -> wisp.internal_server_error()
  }
}

pub fn handle(
  request: wisp.Request,
  repo: create_product_port.T,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Post)
  use payload <- wisp.require_json(request)

  case request_mapper.map_payload(payload) {
    Error(message) -> handler_helpers.bad_request(message)
    Ok(#(name, parent_product_id)) -> {
      case create_product.execute(repo, name, parent_product_id) {
        Ok(result) -> {
          let body = response_mapper.map_create_product_response(result)
          wisp.json_response(body, 201)
        }
        Error(error) -> create_error_response(error)
      }
    }
  }
}
