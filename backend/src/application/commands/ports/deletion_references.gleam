import domain/products/deletion/references
import domain/products/product

pub type Error {
  DatabaseFailure
  InvalidReferenceData
}

pub type T {
  T(load: fn(product.Id) -> Result(references.T, Error))
}
