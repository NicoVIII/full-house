import application/shared/infrastructure_error
import common/product_id
import domain/stock_items/stock_item

pub type ProductExistence =
  fn(product_id.T) -> Result(Bool, infrastructure_error.T)

pub type Create =
  fn(stock_item.T) -> Result(Nil, infrastructure_error.T)

pub type T {
  Ports(does_product_exist: ProductExistence, create: Create)
}
