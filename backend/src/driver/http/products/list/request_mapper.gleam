import application/queries/common/page_limit
import application/queries/common/page_offset
import driver/http/pagination_request_mapper
import gleam/result

pub fn map_query(
  query: List(#(String, String)),
) -> Result(#(page_limit.T, page_offset.T), String) {
  use #(limit, offset) <- result.try(
    pagination_request_mapper.map_limit_and_offset(query),
  )

  Ok(#(limit, offset))
}
