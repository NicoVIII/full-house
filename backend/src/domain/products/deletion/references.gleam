import domain/basics/conditional
import domain/basics/non_empty_set
import gleam/list
import gleam/string

pub opaque type T {
  ProductDeletionReferences(stock_item_count: Int, child_product_count: Int)
}

pub type ValidationError {
  NegativeStockItemCount
  NegativeChildProductCount
}

pub fn new(
  stock_item_count: Int,
  child_product_count: Int,
) -> Result(T, non_empty_set.T(ValidationError)) {
  let errors =
    []
    |> conditional.prepend_if(stock_item_count < 0, NegativeStockItemCount)
    |> conditional.prepend_if(
      child_product_count < 0,
      NegativeChildProductCount,
    )

  case non_empty_set.from_list(errors) {
    Error(_) ->
      Ok(ProductDeletionReferences(
        stock_item_count: stock_item_count,
        child_product_count: child_product_count,
      ))
    Ok(validation_errors) -> Error(validation_errors)
  }
}

fn error_message(error: ValidationError) -> String {
  case error {
    NegativeStockItemCount ->
      "ProductDeletionReferences stock_item_count must be non-negative"
    NegativeChildProductCount ->
      "ProductDeletionReferences child_product_count must be non-negative"
  }
}

fn join_error_messages(errors: non_empty_set.T(ValidationError)) -> String {
  errors
  |> non_empty_set.to_list
  |> list.map(error_message)
  |> string.join("; ")
}

pub fn new_exn(stock_item_count: Int, child_product_count: Int) -> T {
  case new(stock_item_count, child_product_count) {
    Ok(references) -> references
    Error(errors) -> panic as join_error_messages(errors)
  }
}

pub fn stock_item_count(references: T) -> Int {
  let ProductDeletionReferences(stock_item_count:, ..) = references
  stock_item_count
}

pub fn child_product_count(references: T) -> Int {
  let ProductDeletionReferences(child_product_count:, ..) = references
  child_product_count
}
