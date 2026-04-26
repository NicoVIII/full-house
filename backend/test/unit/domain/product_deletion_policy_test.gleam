import domain/product_deletion_policy
import gleeunit/should

pub fn can_delete_with_zero_stock_and_no_children_returns_ok_test() {
  let result = product_deletion_policy.can_delete(0, 0)

  should.equal(result, Ok(Nil))
}

pub fn can_delete_with_one_stock_item_returns_error_test() {
  let result = product_deletion_policy.can_delete(1, 0)

  should.equal(result, Error(product_deletion_policy.ProductHasStockItems))
}

pub fn can_delete_with_multiple_stock_items_returns_error_test() {
  let result = product_deletion_policy.can_delete(5, 0)

  should.equal(result, Error(product_deletion_policy.ProductHasStockItems))
}

pub fn can_delete_with_no_stock_but_child_products_returns_error_test() {
  let result = product_deletion_policy.can_delete(0, 1)

  should.equal(result, Error(product_deletion_policy.ProductHasChildProducts))
}

pub fn can_delete_with_no_stock_but_multiple_children_returns_error_test() {
  let result = product_deletion_policy.can_delete(0, 3)

  should.equal(result, Error(product_deletion_policy.ProductHasChildProducts))
}

pub fn can_delete_prioritizes_stock_items_check_test() {
  let result = product_deletion_policy.can_delete(2, 1)

  should.equal(result, Error(product_deletion_policy.ProductHasStockItems))
}
