import application/queries/common/page_limit
import application/queries/common/page_offset
import gleam/int
import gleam/list
import gleam/result

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

pub fn map_limit_and_offset(
  query: List(#(String, String)),
) -> Result(#(page_limit.T, page_offset.T), String) {
  use limit <- result.try(map_limit_param(query))
  use offset <- result.try(map_offset_param(query))

  Ok(#(limit, offset))
}
