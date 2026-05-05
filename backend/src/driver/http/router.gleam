import composition
import driver/http/products/create/handler as products_create_handler
import driver/http/products/delete/handler as products_delete_handler
import driver/http/products/get/handler as products_get_handler
import driver/http/products/list/handler as products_list_handler
import driver/http/stock_items/list/handler as stock_items_list_handler
import envoy
import gleam/http
import simplifile
import wisp

fn static_dir() -> String {
  case envoy.get("STATIC_DIR") {
    Ok(dir) -> dir
    Error(Nil) -> "./static"
  }
}

fn serve_index(dir: String) -> wisp.Response {
  case simplifile.read(dir <> "/index.html") {
    Ok(html) -> wisp.html_response(html, 200)
    // nolint: thrown_away_error
    Error(_) -> wisp.internal_server_error()
  }
}

fn products_route(
  request: wisp.Request,
  context: composition.AppContext,
) -> wisp.Response {
  case request.method {
    http.Get ->
      products_list_handler.handle(request, context.list_products_port)
    http.Post ->
      products_create_handler.handle(request, context.create_product_ports)
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Post])
  }
}

fn products_detail_route(
  id_raw id_raw: String,
  request request: wisp.Request,
  ctx context: composition.AppContext,
) -> wisp.Response {
  case request.method {
    http.Delete ->
      products_delete_handler.handle(id_raw, context.delete_product_ports)
    http.Get -> products_get_handler.handle(id_raw, context.get_product_port)
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Delete])
  }
}

fn stock_items_route(
  request: wisp.Request,
  context: composition.AppContext,
) -> wisp.Response {
  case request.method {
    http.Get ->
      stock_items_list_handler.handle(request, context.list_stock_items_port)
    _ -> wisp.method_not_allowed(allowed: [http.Get])
  }
}

fn handle_api_request(
  request request: wisp.Request,
  ctx ctx: composition.AppContext,
) -> wisp.Response {
  case wisp.path_segments(request) {
    ["api", "v1", "products"] -> products_route(request, ctx)
    ["api", "v1", "products", id_raw] ->
      products_detail_route(id_raw:, request:, ctx:)
    ["api", "v1", "stock_items"] -> stock_items_route(request, ctx)
    _ -> wisp.not_found()
  }
}

pub fn handle_request(
  request request: wisp.Request,
  ctx ctx: composition.AppContext,
) -> wisp.Response {
  let dir = static_dir()
  use <- wisp.serve_static(request, under: "/", from: dir)
  case wisp.path_segments(request) {
    ["api", ..] -> handle_api_request(request:, ctx:)
    _ -> serve_index(dir)
  }
}
