import application/queries/list_products
import driver/http/handler_helpers
import driver/http/pagination_request_mapper
import driver/http/products/list/response_mapper
import gleam/http
import wisp

pub fn handle(
  request: wisp.Request,
  port: list_products.ListProductsPort,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Get)

  let query = wisp.get_query(request)

  use #(limit, offset) <-
    pagination_request_mapper.map_limit_and_offset(query)
    |> handler_helpers.on_error(handler_helpers.bad_request)

  use result <-
    list_products.execute(limit, offset, port)
    |> handler_helpers.on_error_value(wisp.internal_server_error())

  let body = response_mapper.map_list_products_response(result)
  wisp.json_response(body, 200)
}
