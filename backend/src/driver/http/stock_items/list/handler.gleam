import application/queries/list_stock_items
import driver/http/handler_helpers
import driver/http/pagination_request_mapper
import driver/http/stock_items/list/response_mapper
import driver/http/wire_format
import gleam/http
import wisp

pub fn handle(
  request request: wisp.Request,
  port port: list_stock_items.ListStockItemsPort,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Get)

  let query = wisp.get_query(request)

  use paging_params <-
    pagination_request_mapper.map_paging_params(query)
    |> handler_helpers.on_error(fn(error) {
      pagination_request_mapper.error_to_string(error)
      |> handler_helpers.bad_request
    })

  use result <-
    list_stock_items.execute(paging_params, port)
    |> handler_helpers.on_error_value(wisp.internal_server_error())

  let format = wire_format.from_accept_header(request)
  wisp.response(200)
  |> response_mapper.map_list_stock_response(result, format)
}
