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
) -> Result(T, ValidationError) {
  case stock_item_count < 0, child_product_count < 0 {
    True, _ -> Error(NegativeStockItemCount)
    False, True -> Error(NegativeChildProductCount)
    False, False ->
      Ok(ProductDeletionReferences(
        stock_item_count: stock_item_count,
        child_product_count: child_product_count,
      ))
  }
}

pub fn new_exn(stock_item_count: Int, child_product_count: Int) -> T {
  case new(stock_item_count, child_product_count) {
    Ok(references) -> references
    Error(NegativeStockItemCount) ->
      panic as "ProductDeletionReferences stock_item_count must be non-negative"
    Error(NegativeChildProductCount) ->
      panic as "ProductDeletionReferences child_product_count must be non-negative"
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
