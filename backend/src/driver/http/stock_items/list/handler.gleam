import application/queries/list_stock_items
import driver/http/handler_helpers
import driver/http/pagination_request_mapper
import driver/http/stock_items/list/response_mapper
import gleam/http
import wisp

pub fn handle(
  request: wisp.Request,
  port: list_stock_items.ListStockItemsPort,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Get)

  let query = wisp.get_query(request)
  case pagination_request_mapper.map_limit_and_offset(query) {
    Error(message) -> handler_helpers.bad_request(message)
    Ok(#(limit, offset)) -> {
      use result <-
        list_stock_items.execute(limit, offset, port)
        |> handler_helpers.on_error_value(wisp.internal_server_error())

      let body = response_mapper.map_list_stock_response(result)
      wisp.json_response(body, 200)
    }
  }
}
