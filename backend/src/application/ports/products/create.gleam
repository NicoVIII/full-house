import domain/product

pub type Error {
  DatabaseFailure
  ParentProductNotFound
}

pub type T {
  T(create: fn(product.T) -> Result(Nil, Error))
}
