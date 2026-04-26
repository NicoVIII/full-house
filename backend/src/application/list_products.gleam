import application/page_limit
import application/page_offset
import application/ports/products/list as product_list_port
import domain/product
import gleam/result

pub type ListProductsResult {
  ListProductsResult(
    data: List(product.T),
    total: Int,
    offset: page_offset.T,
    limit: page_limit.T,
  )
}

pub fn execute(
  repo: product_list_port.T,
  offset: page_offset.T,
  limit: page_limit.T,
) -> Result(ListProductsResult, product_list_port.Error) {
  use list_result <- result.try(
    repo.list(product_list_port.Params(offset: offset, limit: limit)),
  )

  Ok(ListProductsResult(
    data: list_result.items,
    total: list_result.total,
    offset: offset,
    limit: limit,
  ))
}
