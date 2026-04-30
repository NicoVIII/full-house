import domain/product

pub type Error {
  DatabaseFailure
  ProductNotFound
  ProductStillReferenced
}

pub type T {
  T(delete: fn(product.Id) -> Result(Nil, Error))
}
