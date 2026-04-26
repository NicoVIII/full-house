import application/page_limit
import application/page_offset
import application/ports/product_repository
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
  repo: product_repository.T,
  offset: page_offset.T,
  limit: page_limit.T,
) -> Result(ListProductsResult, Nil) {
  use list_result <- result.try(
    repo.list(product_repository.ListParams(offset: offset, limit: limit)),
  )

  Ok(ListProductsResult(
    data: list_result.items,
    total: list_result.total,
    offset: offset,
    limit: limit,
  ))
}
