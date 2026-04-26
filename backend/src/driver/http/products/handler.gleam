import application/ports/products/create as create_product_port
import application/ports/products/list as list_product_port
import driver/http/products/create/handler as create_handler
import driver/http/products/list/handler as list_handler
import gleam/http
import wisp

pub fn handle(
  request: wisp.Request,
  list_repo: list_product_port.T,
  create_repo: create_product_port.T,
) -> wisp.Response {
  case request.method {
    http.Get -> list_handler.handle(request, list_repo)
    http.Post -> create_handler.handle(request, create_repo)
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Post])
  }
}
