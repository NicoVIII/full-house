import common/product_id
import domain/products/existing_product_id
import domain/products/product_name
import gleam/option.{type Option}

pub type T {
  T(
    id: product_id.T,
    name: product_name.T,
    parent_product_id: Option(existing_product_id.T),
  )
}
