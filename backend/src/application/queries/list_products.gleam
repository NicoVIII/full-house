import application/queries/page_limit
import application/queries/page_offset
import application/queries/ports/list as product_list_port
import domain/products/product
import gleam/option.{type Option}
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
  parent_product_id: Option(product.Id),
) -> Result(ListProductsResult, product_list_port.Error) {
  use list_result <- result.try(
    repo.list(product_list_port.Params(
      offset: offset,
      limit: limit,
      parent_product_id: parent_product_id,
    )),
  )

  Ok(ListProductsResult(
    data: list_result.items,
    total: list_result.total,
    offset: offset,
    limit: limit,
  ))
}
