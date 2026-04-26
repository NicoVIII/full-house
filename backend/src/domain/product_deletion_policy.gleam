/// Business rules: products cannot be deleted if:
/// 1. Stock items reference them
/// 2. Child products reference them (they have a parent_product_id pointing to them)
///
/// This module encodes the core invariants as a pure domain policy.
/// It is called early in the application layer (before persistence) to prevent
/// deletion attempts that violate the rules.
pub type CannotDeleteReason {
  ProductHasStockItems
  ProductHasChildProducts
}

/// Check whether a product can be deleted based on references.
///
/// Returns Ok(Nil) if the product has no stock or child product references and can be deleted.
/// Returns Error with the first reason that prevents deletion if references exist.
pub fn can_delete(
  stock_item_count: Int,
  child_product_count: Int,
) -> Result(Nil, CannotDeleteReason) {
  case stock_item_count {
    0 ->
      case child_product_count {
        0 -> Ok(Nil)
        _ -> Error(ProductHasChildProducts)
      }
    _ -> Error(ProductHasStockItems)
  }
}
