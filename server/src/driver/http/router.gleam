import composition
import driver/http/products/create/handler as products_create_handler
import driver/http/products/delete/handler as products_delete_handler
import driver/http/products/get/handler as products_get_handler
import driver/http/products/get_by_barcode/handler as products_get_by_barcode_handler
import driver/http/products/list/handler as products_list_handler
import driver/http/products/update_barcodes/handler as products_update_barcodes_handler
import driver/http/stock_items/create/handler as stock_items_create_handler
import driver/http/stock_items/list/handler as stock_items_list_handler
import driver/http/stock_items/remove/handler as stock_items_remove_handler
import gleam/http
import wisp

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
    http.Get ->
      products_get_handler.handle(id_raw, request, context.get_product_port)
    http.Patch ->
      products_update_barcodes_handler.handle(
        id_raw,
        request,
        context.update_product_barcodes_port,
        context.get_product_port,
      )
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Delete, http.Patch])
  }
}

fn products_barcode_route(
  barcode_raw barcode_raw: String,
  request request: wisp.Request,
  context context: composition.AppContext,
) -> wisp.Response {
  case request.method {
    http.Get ->
      products_get_by_barcode_handler.handle(
        barcode_raw,
        request,
        context.get_product_by_barcode_port,
      )
    _ -> wisp.method_not_allowed(allowed: [http.Get])
  }
}

fn stock_items_route(
  request: wisp.Request,
  context: composition.AppContext,
) -> wisp.Response {
  case request.method {
    http.Get ->
      stock_items_list_handler.handle(request, context.list_stock_items_port)
    http.Post ->
      stock_items_create_handler.handle(
        request,
        context.create_stock_item_ports,
      )
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Post])
  }
}

fn stock_items_detail_route(
  product_id_raw product_id_raw: String,
  best_before_date_raw best_before_date_raw: String,
  request request: wisp.Request,
  context context: composition.AppContext,
) -> wisp.Response {
  case request.method {
    http.Delete ->
      stock_items_remove_handler.handle(
        product_id_raw,
        best_before_date_raw,
        request,
        context.remove_stock_item_port,
      )
    _ -> wisp.method_not_allowed(allowed: [http.Delete])
  }
}

pub fn handle_api_request(
  request request: wisp.Request,
  ctx ctx: composition.AppContext,
) -> wisp.Response {
  case wisp.path_segments(request) {
    ["api", "v1", "products"] -> products_route(request, ctx)
    ["api", "v1", "products", "by-barcode", barcode_raw] ->
      products_barcode_route(barcode_raw:, request:, context: ctx)
    ["api", "v1", "products", id_raw] ->
      products_detail_route(id_raw:, request:, ctx:)
    ["api", "v1", "stock_items"] -> stock_items_route(request, ctx)
    ["api", "v1", "stock_items", product_id_raw, best_before_date_raw] ->
      stock_items_detail_route(
        product_id_raw:,
        best_before_date_raw:,
        request:,
        context: ctx,
      )
    _ -> wisp.not_found()
  }
}
