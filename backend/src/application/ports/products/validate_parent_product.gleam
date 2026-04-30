import domain/products/creation/validated_parent_id
import domain/products/product
import gleam/option.{type Option}

pub type Error {
  DatabaseFailure
  ParentProductNotFound
}

pub type T {
  T(
    validate: fn(Option(product.Id)) ->
      Result(Option(validated_parent_id.T), Error),
  )
}
