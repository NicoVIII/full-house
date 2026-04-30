import application/list_products
import application/ports/products/list as product_list_port
import driver/http/handler_helpers
import driver/http/pagination_request_mapper
import driver/http/products/list/response_mapper
import wisp

pub fn handle(
  request: wisp.Request,
  repo: product_list_port.T,
) -> wisp.Response {
  let query = wisp.get_query(request)
  case pagination_request_mapper.map_offset_and_limit(query) {
    Error(message) -> handler_helpers.bad_request(message)
    Ok(#(offset, limit)) -> {
      use result <- handler_helpers.handle_result(
        list_products.execute(repo, offset, limit),
        wisp.internal_server_error(),
      )

      let body = response_mapper.map_list_products_response(result)
      wisp.json_response(body, 200)
    }
  }
}
