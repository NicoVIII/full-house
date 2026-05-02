import common/product_id

pub opaque type T {
  ExistingProductId(product_id.T)
}

pub type ExistenceError {
  ProductNotFound
}

pub fn prove(id: product_id.T, exists: Bool) -> Result(T, ExistenceError) {
  case exists {
    True -> Ok(ExistingProductId(id))
    False -> Error(ProductNotFound)
  }
}

pub fn value(existing_id: T) -> String {
  let ExistingProductId(id) = existing_id
  product_id.value(id)
}
