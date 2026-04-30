import application/ports/products/create as create_product_port
import application/ports/products/delete as delete_product_port
import application/ports/products/deletion_references as deletion_references_port
import application/ports/products/get as get_product_port
import application/ports/products/list as list_product_port
import application/ports/products/list_child_ids as list_child_ids_port
import application/ports/products/validate_parent_product as validate_parent_product_port
import driver/http/products/create/handler as create_handler
import driver/http/products/delete/handler as delete_handler
import driver/http/products/get/handler as get_handler
import driver/http/products/list/handler as list_handler
import gleam/http
import wisp

pub fn handle(
  request: wisp.Request,
  get_repo: get_product_port.T,
  list_repo: list_product_port.T,
  validate_parent_repo: validate_parent_product_port.T,
  create_repo: create_product_port.T,
  references_repo: deletion_references_port.T,
  delete_repo: delete_product_port.T,
  child_ids_repo: list_child_ids_port.T,
) -> wisp.Response {
  case request.method {
    http.Get ->
      case wisp.path_segments(request) {
        ["api", "v1", "products"] ->
          list_handler.handle(request, list_repo, child_ids_repo)
        ["api", "v1", "products", _] ->
          get_handler.handle(request, get_repo, child_ids_repo)
        _ -> wisp.not_found()
      }
    http.Post ->
      create_handler.handle(request, validate_parent_repo, create_repo)
    http.Delete -> delete_handler.handle(request, references_repo, delete_repo)
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Post, http.Delete])
  }
}
