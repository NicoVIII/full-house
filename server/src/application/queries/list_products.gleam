import application/queries/common/paging
import application/queries/common/product_query_model
import application/shared/infrastructure_error

pub type Response =
  paging.Response(product_query_model.T)

pub type ListProductsPort =
  fn(paging.Params) -> Result(Response, infrastructure_error.T)

pub fn execute(
  paging paging_params: paging.Params,
  port list_products: ListProductsPort,
) -> Result(Response, infrastructure_error.T) {
  list_products(paging_params)
}
