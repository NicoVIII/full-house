import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/product_query_model
import application/shared/infrastructure_error

pub type ListProductsResult {
  ListProductsResult(
    data: List(product_query_model.T),
    limit: page_limit.T,
    offset: page_offset.T,
    total: Int,
  )
}

pub type ListProductsPort =
  fn(page_limit.T, page_offset.T) ->
    Result(ListProductsResult, infrastructure_error.T)

pub fn execute(
  limit: page_limit.T,
  offset: page_offset.T,
  list_products: ListProductsPort,
) -> Result(ListProductsResult, infrastructure_error.T) {
  list_products(limit, offset)
}
