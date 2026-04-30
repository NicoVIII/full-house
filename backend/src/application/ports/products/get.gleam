import domain/products/product

pub type Error {
  DatabaseFailure
  InvalidData
  ProductNotFound
}

pub type T {
  T(get: fn(product.Id) -> Result(product.T, Error))
}
