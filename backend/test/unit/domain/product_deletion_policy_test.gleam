import domain/product_deletion_policy
import domain/product_deletion_references
import gleeunit/should

pub fn decide_with_no_references_returns_can_delete_test() {
  let references = product_deletion_references.new_exn(0, 0)
  let decision = product_deletion_policy.decide(references)

  should.equal(decision, product_deletion_policy.CanDelete)
}

pub fn decide_with_stock_and_children_returns_both_blockers_test() {
  let references = product_deletion_references.new_exn(2, 3)
  let decision = product_deletion_policy.decide(references)

  should.equal(
    decision,
    product_deletion_policy.CannotDelete([
      product_deletion_policy.HasStockItems(2),
      product_deletion_policy.HasChildProducts(3),
    ]),
  )
}

pub fn can_delete_with_zero_stock_and_no_children_returns_ok_test() {
  let references = product_deletion_references.new_exn(0, 0)
  let result = product_deletion_policy.can_delete(references)

  should.equal(result, Ok(Nil))
}

pub fn can_delete_with_one_stock_item_returns_error_test() {
  let references = product_deletion_references.new_exn(1, 0)
  let result = product_deletion_policy.can_delete(references)

  should.equal(result, Error(product_deletion_policy.ProductHasStockItems))
}

pub fn can_delete_with_multiple_stock_items_returns_error_test() {
  let references = product_deletion_references.new_exn(5, 0)
  let result = product_deletion_policy.can_delete(references)

  should.equal(result, Error(product_deletion_policy.ProductHasStockItems))
}

pub fn can_delete_with_no_stock_but_child_products_returns_error_test() {
  let references = product_deletion_references.new_exn(0, 1)
  let result = product_deletion_policy.can_delete(references)

  should.equal(result, Error(product_deletion_policy.ProductHasChildProducts))
}

pub fn can_delete_with_no_stock_but_multiple_children_returns_error_test() {
  let references = product_deletion_references.new_exn(0, 3)
  let result = product_deletion_policy.can_delete(references)

  should.equal(result, Error(product_deletion_policy.ProductHasChildProducts))
}

pub fn can_delete_prioritizes_stock_items_check_test() {
  let references = product_deletion_references.new_exn(2, 1)
  let result = product_deletion_policy.can_delete(references)

  should.equal(result, Error(product_deletion_policy.ProductHasStockItems))
}

pub fn deletion_references_reject_negative_counts_test() {
  let result = product_deletion_references.new(-1, 0)

  should.equal(
    result,
    Error(product_deletion_references.NegativeStockItemCount),
  )
}
