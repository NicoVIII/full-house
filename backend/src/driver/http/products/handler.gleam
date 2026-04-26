import application/list_products
import application/page_limit
import application/page_offset
import application/ports/product_repository
import driver/http/products/response_mapper
import gleam/http
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import wisp

fn handle_result(
  value: Result(a, e),
  error_response: wisp.Response,
  next: fn(a) -> wisp.Response,
) -> wisp.Response {
  case value {
    Ok(ok) -> next(ok)
    Error(_) -> error_response
  }
}

fn bad_request(message: String) -> wisp.Response {
  json.object([
    #("error", json.string("invalid_parameter")),
    #("message", json.string(message)),
  ])
  |> json.to_string
  |> fn(body) { wisp.json_response(body, 400) }
}

// Request mapping: HTTP query params -> application input

fn parse_int_param(raw: String, parse_error: String) -> Result(Int, String) {
  case int.parse(raw) {
    Ok(n) -> Ok(n)
    Error(_) -> Error(parse_error)
  }
}

fn map_offset_raw(raw: String) -> Result(page_offset.T, String) {
  use n <- result.try(parse_int_param(raw, "offset must be an integer"))

  case page_offset.new(n) {
    Ok(offset) -> Ok(offset)
    Error(_) -> Error("offset must be greater than or equal to 0")
  }
}

fn map_limit_raw(raw: String) -> Result(page_limit.T, String) {
  use n <- result.try(parse_int_param(raw, "limit must be an integer"))

  case page_limit.new(n) {
    Ok(limit) -> Ok(limit)
    Error(_) -> Error("limit must be between 1 and 100")
  }
}

fn map_offset_param(
  query: List(#(String, String)),
) -> Result(page_offset.T, String) {
  case list.key_find(query, "offset") {
    Error(_) -> Ok(page_offset.default())
    Ok(raw) -> map_offset_raw(raw)
  }
}

fn map_limit_param(
  query: List(#(String, String)),
) -> Result(page_limit.T, String) {
  case list.key_find(query, "limit") {
    Error(_) -> Ok(page_limit.default())
    Ok(raw) -> map_limit_raw(raw)
  }
}

fn map_list_products_request(
  query: List(#(String, String)),
) -> Result(#(page_offset.T, page_limit.T), String) {
  use offset <- result.try(map_offset_param(query))
  use limit <- result.try(map_limit_param(query))

  Ok(#(offset, limit))
}

pub fn handle(
  request: wisp.Request,
  repo: product_repository.T,
) -> wisp.Response {
  use <- wisp.require_method(request, http.Get)

  let query = wisp.get_query(request)
  case map_list_products_request(query) {
    Error(message) -> bad_request(message)
    Ok(#(offset, limit)) -> {
      use result <- handle_result(
        list_products.execute(repo, offset, limit),
        wisp.internal_server_error(),
      )

      let body = response_mapper.map_list_products_response(result)
      wisp.json_response(body, 200)
    }
  }
}
