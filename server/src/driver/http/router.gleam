import composition
import driver/http/products/create as products_create_handler
import driver/http/products/delete as products_delete_handler
import driver/http/products/get as products_get_handler
import driver/http/products/get_by_barcode as products_get_by_barcode_handler
import driver/http/products/list/handler as products_list_handler
import driver/http/products/update as products_update_handler
import driver/http/stock_items/create as stock_items_create_handler
import driver/http/stock_items/delete as stock_items_delete_handler
import driver/http/stock_items/list/handler as stock_items_list_handler
import gleam/http
import wisp

fn products_route(
  request: wisp.Request,
  context: composition.AppProductsContext,
) -> wisp.Response {
  case request.method {
    http.Get ->
      products_list_handler.handle(request, context.query_context.list_port)
    http.Post ->
      products_create_handler.handle(
        request,
        context.command_context.create_ports,
      )
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Post])
  }
}

fn products_detail_route(
  id_raw id_raw: String,
  request request: wisp.Request,
  ctx context: composition.AppProductsContext,
) -> wisp.Response {
  case request.method {
    http.Delete ->
      products_delete_handler.handle(
        id_raw,
        context.command_context.delete_ports,
      )
    http.Get ->
      products_get_handler.handle(
        id_raw,
        request,
        context.query_context.get_port,
      )
    http.Patch ->
      products_update_handler.handle(
        id_raw,
        request,
        context.command_context.update_ports,
      )
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Delete, http.Patch])
  }
}

fn products_barcode_route(
  request: wisp.Request,
  context: composition.AppProductsContext,
) -> wisp.Response {
  case request.method {
    http.Get ->
      products_get_by_barcode_handler.handle(
        request,
        context.query_context.get_by_barcode_port,
      )
    _ -> wisp.method_not_allowed(allowed: [http.Get])
  }
}

fn stock_items_route(
  request: wisp.Request,
  context: composition.AppStockItemsContext,
) -> wisp.Response {
  case request.method {
    http.Get ->
      stock_items_list_handler.handle(request, context.query_context.list_port)
    http.Post ->
      stock_items_create_handler.handle(
        request,
        context.command_context.create_ports,
      )
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Post])
  }
}

fn stock_items_detail_route(
  product_id_raw product_id_raw: String,
  best_before_date_raw best_before_date_raw: String,
  request request: wisp.Request,
  context context: composition.AppStockItemsContext,
) -> wisp.Response {
  case request.method {
    http.Delete ->
      stock_items_delete_handler.handle(
        product_id_raw,
        best_before_date_raw,
        request,
        context.command_context.delete_ports,
      )
    _ -> wisp.method_not_allowed(allowed: [http.Delete])
  }
}

pub fn handle_api_request(
  request request: wisp.Request,
  ctx ctx: composition.AppContext,
) -> wisp.Response {
  case wisp.path_segments(request) {
    ["api", "v1", "products"] -> products_route(request, ctx.product_context)
    ["api", "v1", "products", "by-barcode"] ->
      products_barcode_route(request, ctx.product_context)
    ["api", "v1", "products", id_raw] ->
      products_detail_route(id_raw:, request:, ctx: ctx.product_context)
    ["api", "v1", "stock_items"] ->
      stock_items_route(request, ctx.stock_item_context)
    ["api", "v1", "stock_items", product_id_raw, best_before_date_raw] ->
      stock_items_detail_route(
        product_id_raw:,
        best_before_date_raw:,
        request:,
        context: ctx.stock_item_context,
      )
    _ -> wisp.not_found()
  }
}
