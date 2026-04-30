import domain/basics/uuid
import domain/products/product_name
import gleam/option.{type Option}

pub type Id {
  ProductId(value: uuid.T)
}

pub type T {
  Product(id: Id, name: product_name.T, parent_product_id: Option(Id))
}
