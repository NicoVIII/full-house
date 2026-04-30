import domain/basics/non_empty_set
import domain/products/deletion/policy as product_deletion_policy
import domain/products/deletion/references as product_deletion_references
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

pub fn decide_with_stock_items_returns_cannot_delete_test() {
  let references = product_deletion_references.new_exn(1, 0)
  let decision = product_deletion_policy.decide(references)

  should.equal(
    decision,
    product_deletion_policy.CannotDelete([
      product_deletion_policy.HasStockItems(1),
    ]),
  )
}

pub fn decide_with_child_products_returns_cannot_delete_test() {
  let references = product_deletion_references.new_exn(0, 1)
  let decision = product_deletion_policy.decide(references)

  should.equal(
    decision,
    product_deletion_policy.CannotDelete([
      product_deletion_policy.HasChildProducts(1),
    ]),
  )
}

pub fn deletion_references_reject_negative_counts_test() {
  let result = product_deletion_references.new(-1, 0)

  should.equal(
    result,
    Error(non_empty_set.new(product_deletion_references.NegativeStockItemCount)),
  )
}
