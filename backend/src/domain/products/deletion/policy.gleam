/// Business rules: products cannot be deleted if:
/// 1. Stock items reference them
/// 2. Child products reference them (they have a parent_product_id pointing to them)
///
/// This module encodes the core invariants as a pure domain policy.
import domain/products/deletion/references as product_deletion_references

pub type Blocker {
  HasStockItems(count: Int)
  HasChildProducts(count: Int)
}

pub type Decision {
  CanDelete
  CannotDelete(blockers: List(Blocker))
}

pub fn decide(references: product_deletion_references.T) -> Decision {
  let stock_item_count =
    product_deletion_references.stock_item_count(references)
  let child_product_count =
    product_deletion_references.child_product_count(references)

  case stock_item_count > 0, child_product_count > 0 {
    False, False -> CanDelete
    True, False -> CannotDelete([HasStockItems(stock_item_count)])
    False, True -> CannotDelete([HasChildProducts(child_product_count)])
    True, True ->
      CannotDelete([
        HasStockItems(stock_item_count),
        HasChildProducts(child_product_count),
      ])
  }
}
