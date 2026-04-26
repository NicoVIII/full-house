/// Port for checking if a product has child products (i.e., products with
/// parent_product_id pointing to it).
///
/// This is an outbound port that allows the application layer to query
/// whether a product can be deleted based on existing child products.
import domain/product

pub type Error {
  DatabaseFailure
}

pub type T {
  T(count_by_parent_id: fn(product.Id) -> Result(Int, Error))
}
