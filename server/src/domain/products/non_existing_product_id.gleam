import common/product_id
import gleam/bool

pub opaque type T {
  NonExistingProductId(product_id.T)
}

pub type ExistenceError {
  ProductAlreadyExists
}

pub fn prove(
  id id: product_id.T,
  exists exists: Bool,
) -> Result(T, ExistenceError) {
  use <- bool.guard(exists, Error(ProductAlreadyExists))
  Ok(NonExistingProductId(id))
}

pub fn to_product_id(non_existing_id: T) -> product_id.T {
  let NonExistingProductId(id) = non_existing_id
  id
}

pub fn to_value(non_existing_id: T) -> String {
  to_product_id(non_existing_id)
  |> product_id.to_value
}
