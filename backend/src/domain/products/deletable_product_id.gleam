import common/product_id
import domain/basics/conditional
import domain/basics/non_empty_set
import domain/products/product

pub opaque type T {
  DeletableProductId(product_id.T)
}

pub type DeletionError {
  HasChildren
  HasStockItems
}

pub fn prove(
  product product: product.T,
  has_children has_children: Bool,
  has_stock_items has_stock_items: Bool,
) -> Result(T, non_empty_set.T(DeletionError)) {
  let errors =
    []
    |> conditional.prepend_if(has_children, HasChildren)
    |> conditional.prepend_if(has_stock_items, HasStockItems)

  case non_empty_set.from_list(errors) {
    Error(_) -> Ok(DeletableProductId(product.id))
    Ok(validation_errors) -> Error(validation_errors)
  }
}

pub fn value(deletable_product_id: T) -> String {
  let DeletableProductId(id) = deletable_product_id
  product_id.value(id)
}
