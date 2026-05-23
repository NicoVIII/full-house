import application/queries/common/product_query_model
import application/shared/infrastructure_error
import common/product_id

pub type GetProductError {
  ProductNotFound
  InfrastructureError(infrastructure_error.T)
}

pub type GetProductPort =
  fn(product_id.T) -> Result(product_query_model.T, GetProductError)

pub fn execute(
  for id: product_id.T,
  port get_product: GetProductPort,
) -> Result(product_query_model.T, GetProductError) {
  get_product(id)
}
