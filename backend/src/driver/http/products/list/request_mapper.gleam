import application/page_limit
import application/page_offset
import domain/basics/uuid
import domain/products/product
import driver/http/pagination_request_mapper
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

fn map_parent_product_id(
  query: List(#(String, String)),
) -> Result(Option(product.Id), String) {
  case list.key_find(query, "parent_product_id") {
    Error(_) -> Ok(None)
    Ok(raw) ->
      uuid.new(raw)
      |> result.map(product.ProductId)
      |> result.map(Some)
      |> result.map_error(fn(_) { "parent_product_id must be a valid UUID" })
  }
}

pub fn map_query(
  query: List(#(String, String)),
) -> Result(#(page_offset.T, page_limit.T, Option(product.Id)), String) {
  use #(offset, limit) <- result.try(
    pagination_request_mapper.map_offset_and_limit(query),
  )
  use parent_product_id <- result.try(map_parent_product_id(query))

  Ok(#(offset, limit, parent_product_id))
}
