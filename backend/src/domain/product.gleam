import domain/basics/uuid
import gleam/option.{type Option}

pub type Id {
  ProductId(value: uuid.T)
}

pub type T {
  Product(id: Id, name: String, parent_product_id: Option(Id))
}
