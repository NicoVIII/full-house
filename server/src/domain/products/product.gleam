import common/product_id
import domain/basics/conditional
import domain/basics/non_empty_set
import domain/products/barcodes/barcode
import domain/products/barcodes/unassigned_barcode
import domain/products/existing_product_id
import domain/products/non_existing_product_id
import domain/products/product_name
import gleam/bool
import gleam/list
import gleam/option.{type Option}
import gleam/set.{type Set}

pub opaque type T {
  T(
    id: product_id.T,
    name: product_name.T,
    parent_product_id: Option(existing_product_id.T),
    barcodes: Set(barcode.T),
  )
}

// Creates an product without validating the creation business rules
// Should only be used to represent existing products
pub fn hydrate(
  id id: product_id.T,
  name name: product_name.T,
  parent_product_id parent_product_id: Option(existing_product_id.T),
  barcodes barcodes: Set(barcode.T),
) -> T {
  T(id, name, parent_product_id, barcodes)
}

pub fn create(
  id: non_existing_product_id.T,
  name: product_name.T,
  parent_product_id: Option(existing_product_id.T),
  barcodes: Set(unassigned_barcode.T),
) -> T {
  T(
    non_existing_product_id.to_product_id(id),
    name,
    parent_product_id,
    set.map(barcodes, unassigned_barcode.to_barcode),
  )
}

pub fn change_name(product: T, new_name: product_name.T) -> T {
  T(..product, name: new_name)
}

pub fn change_parent_product_id(
  product: T,
  new_parent_product_id: Option(existing_product_id.T),
) -> T {
  T(..product, parent_product_id: new_parent_product_id)
}

pub fn add_barcodes(
  product: T,
  new_barcodes: non_empty_set.T(unassigned_barcode.T),
) -> T {
  T(
    ..product,
    barcodes: set.union(
      product.barcodes,
      set.map(non_empty_set.to_set(new_barcodes), unassigned_barcode.to_barcode),
    ),
  )
}

pub type RemoveBarcodesError {
  BarcodeNotAssignedToProduct
}

pub fn remove_barcodes(
  product: T,
  barcodes_to_remove: non_empty_set.T(barcode.T),
) -> Result(T, RemoveBarcodesError) {
  let barcodes_to_remove_set = non_empty_set.to_set(barcodes_to_remove)
  use <- bool.guard(
    !set.is_subset(barcodes_to_remove_set, product.barcodes),
    Error(BarcodeNotAssignedToProduct),
  )
  Ok(
    T(
      ..product,
      barcodes: set.difference(product.barcodes, barcodes_to_remove_set),
    ),
  )
}

pub opaque type DeletableId {
  DeletableId(product_id.T)
}

pub fn deletable_id_to_value(deletable_id: DeletableId) -> String {
  let DeletableId(id) = deletable_id
  product_id.to_value(id)
}

pub type DeletionContext {
  DeletionContext(has_children: Bool, has_stock_items: Bool)
}

pub type DeletionError {
  HasChildren
  HasStockItems
}

pub fn delete(
  product product: T,
  context context: DeletionContext,
) -> Result(DeletableId, non_empty_set.T(DeletionError)) {
  let errors =
    []
    |> conditional.prepend_if(context.has_children, HasChildren)
    |> conditional.prepend_if(context.has_stock_items, HasStockItems)

  case non_empty_set.from_list(errors) {
    Error(non_empty_set.EmptyList) -> Ok(DeletableId(product.id))
    Ok(validation_errors) -> Error(validation_errors)
  }
}

// The transparent record used for infrastructure
pub type Snapshot {
  ProductSnapshot(
    id: String,
    name: String,
    parent_product_id: Option(String),
    barcodes: List(String),
  )
}

// The domain grants read-access by projecting its internal state
pub fn to_snapshot(product: T) -> Snapshot {
  ProductSnapshot(
    id: product_id.to_value(product.id),
    name: product_name.to_value(product.name),
    parent_product_id: option.map(
      product.parent_product_id,
      existing_product_id.to_value,
    ),
    barcodes: product.barcodes |> set.to_list |> list.map(barcode.to_value),
  )
}
