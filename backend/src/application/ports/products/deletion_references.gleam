import domain/product
import domain/product_deletion_references

pub type Error {
  DatabaseFailure
  InvalidReferenceData
}

pub type T {
  T(load: fn(product.Id) -> Result(product_deletion_references.T, Error))
}
