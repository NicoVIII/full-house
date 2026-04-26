import domain/product

pub type Error {
  DatabaseFailure
}

pub type T {
  T(count_by_product_id: fn(product.Id) -> Result(Int, Error))
}
