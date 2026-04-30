import domain/products/product
import domain/products/product_name
import gleam/option.{type Option}

pub type T {
  Command(name: product_name.T, parent_product_id: Option(product.Id))
}
