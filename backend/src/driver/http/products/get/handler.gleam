import application/queries/get_product
import application/queries/ports/get as get_product_port
import application/queries/ports/list_child_ids as list_child_ids_port
import domain/basics/uuid
import domain/products/product
import driver/http/handler_helpers
import driver/http/products/get/response_mapper
import gleam/http
import gleam/json
import wisp

pub fn handle(
  request: wisp.Request,
  repo: get_product_port.T,
  child_ids_repo: list_child_ids_port.T,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Get)

  case wisp.path_segments(request) {
    ["api", "v1", "products", id_raw] ->
      handle_get(id_raw, repo, child_ids_repo)
    _ -> wisp.not_found()
  }
}

fn handle_get(
  id_raw: String,
  repo: get_product_port.T,
  child_ids_repo: list_child_ids_port.T,
) -> wisp.Response {
  case uuid.new(id_raw) {
    Error(_) -> handler_helpers.bad_request("product id must be a valid UUID")
    Ok(uid) -> {
      let product_id = product.ProductId(uid)

      case get_product.execute(repo, product_id) {
        Ok(found_product) ->
          wisp.json_response(
            response_mapper.map_get_product_response(
              found_product,
              child_ids_repo,
            ),
            200,
          )
        Error(error) -> error_response(error)
      }
    }
  }
}

fn error_response(error: get_product_port.Error) -> wisp.Response {
  case error {
    get_product_port.ProductNotFound ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("not_found")),
            #("message", json.string("product not found")),
          ]),
        ),
        404,
      )
    get_product_port.InvalidData -> wisp.internal_server_error()
    get_product_port.DatabaseFailure -> wisp.internal_server_error()
  }
}
