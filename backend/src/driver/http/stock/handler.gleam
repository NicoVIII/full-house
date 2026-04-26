import application/list_stock
import application/ports/stock_repository
import driver/http/handler_helpers
import driver/http/pagination_request_mapper
import driver/http/stock/response_mapper
import gleam/http
import wisp

pub fn handle(request: wisp.Request, repo: stock_repository.T) -> wisp.Response {
  use <- wisp.require_method(request, http.Get)

  let query = wisp.get_query(request)
  case pagination_request_mapper.map_offset_and_limit(query) {
    Error(message) -> handler_helpers.bad_request(message)
    Ok(#(offset, limit)) -> {
      use result <- handler_helpers.handle_result(
        list_stock.execute(repo, offset, limit),
        wisp.internal_server_error(),
      )

      let body = response_mapper.map_list_stock_response(result)
      wisp.json_response(body, 200)
    }
  }
}
