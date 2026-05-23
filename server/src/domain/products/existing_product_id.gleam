import common/product_id
import gleam/bool

pub opaque type T {
  ExistingProductId(product_id.T)
}

pub type ExistenceError {
  ProductNotFound
}

pub fn prove(
  id id: product_id.T,
  exists exists: Bool,
) -> Result(T, ExistenceError) {
  use <- bool.guard(!exists, Error(ProductNotFound))
  Ok(ExistingProductId(id))
}

pub fn value(existing_id: T) -> String {
  let ExistingProductId(id) = existing_id
  product_id.value(id)
}
