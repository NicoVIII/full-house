import application/delete_product
import application/ports/products/delete as delete_product_port
import application/ports/products/deletion_references as deletion_references_port
import domain/basics/uuid
import domain/products/deletion/command as delete_product_command
import domain/products/product
import driver/http/handler_helpers
import gleam/http
import gleam/json
import wisp

pub fn handle(
  request: wisp.Request,
  references_repo: deletion_references_port.T,
  delete_repo: delete_product_port.T,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Delete)

  case wisp.path_segments(request) {
    ["api", "v1", "products", id_raw] ->
      handle_delete(id_raw, references_repo, delete_repo)
    _ -> wisp.not_found()
  }
}

fn handle_delete(
  id_raw: String,
  references_repo: deletion_references_port.T,
  delete_repo: delete_product_port.T,
) -> wisp.Response {
  case uuid.new(id_raw) {
    Error(_) -> handler_helpers.bad_request("product id must be a valid UUID")
    Ok(uid) -> {
      let product_id = product.ProductId(uid)
      let command = delete_product_command.Command(product_id: product_id)

      case delete_product.execute(references_repo, delete_repo, command) {
        Ok(Nil) -> wisp.response(204)
        Error(error) -> error_response(error)
      }
    }
  }
}

fn error_response(error: delete_product.Error) -> wisp.Response {
  case error {
    delete_product.ProductNotFound ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("not_found")),
            #("message", json.string("product not found")),
          ]),
        ),
        404,
      )
    delete_product.ProductHasStockItems ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("conflict")),
            #(
              "message",
              json.string("cannot delete product with existing stock items"),
            ),
          ]),
        ),
        409,
      )
    delete_product.ProductHasChildProducts ->
      wisp.json_response(
        json.to_string(
          json.object([
            #("error", json.string("conflict")),
            #(
              "message",
              json.string("cannot delete product with existing child products"),
            ),
          ]),
        ),
        409,
      )
    delete_product.DatabaseFailure -> wisp.internal_server_error()
  }
}
