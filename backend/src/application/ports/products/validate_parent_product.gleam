import domain/product
import domain/validated_parent_product_id
import gleam/option.{type Option}

pub type Error {
  DatabaseFailure
  ParentProductNotFound
}

pub type T {
  T(
    validate: fn(Option(product.Id)) ->
      Result(validated_parent_product_id.T, Error),
  )
}
