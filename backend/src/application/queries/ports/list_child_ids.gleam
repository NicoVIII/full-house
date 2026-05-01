import domain/products/product

pub type Error {
  DatabaseFailure
  InvalidData
}

pub type T {
  T(load: fn(product.Id) -> Result(List(String), Error))
}
