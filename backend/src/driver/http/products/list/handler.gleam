import application/list_products
import application/ports/products/list as product_list_port
import application/ports/products/list_child_ids as list_child_ids_port
import driver/http/handler_helpers
import driver/http/products/list/request_mapper
import driver/http/products/list/response_mapper
import wisp

pub fn handle(
  request: wisp.Request,
  repo: product_list_port.T,
  child_ids_repo: list_child_ids_port.T,
) -> wisp.Response {
  let query = wisp.get_query(request)
  case request_mapper.map_query(query) {
    Error(message) -> handler_helpers.bad_request(message)
    Ok(#(offset, limit, parent_product_id)) -> {
      use result <- handler_helpers.handle_result(
        list_products.execute(repo, offset, limit, parent_product_id),
        wisp.internal_server_error(),
      )

      let body =
        response_mapper.map_list_products_response(result, child_ids_repo)
      wisp.json_response(body, 200)
    }
  }
}
