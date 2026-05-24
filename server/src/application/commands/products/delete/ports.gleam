import application/shared/infrastructure_error
import common/product_id
import domain/products/product

pub type LoadProductError {
  LoadProductNotFound
  LoadProductInfrastructureError(infrastructure_error.T)
}

pub type LoadProduct =
  fn(product_id.T) -> Result(product.T, LoadProductError)

pub type HasChildren =
  fn(product_id.T) -> Result(Bool, infrastructure_error.T)

pub type HasStockItems =
  fn(product_id.T) -> Result(Bool, infrastructure_error.T)

pub type Delete =
  fn(product.DeletableId) -> Result(Nil, infrastructure_error.T)

pub type T {
  Ports(
    load_product: LoadProduct,
    has_children: HasChildren,
    has_stock_items: HasStockItems,
    delete: Delete,
  )
}
