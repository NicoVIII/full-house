import domain/products/product

/// Validated parent product ID — guarantees the parent exists.
/// This is an opaque type to ensure only pre-validated IDs are wrapped.
/// Note: The None case (no parent) is handled by using Option(ValidatedParentProductId) in the application layer.
pub opaque type T {
  ValidatedParentProductId(id: product.Id)
}

/// Construct a validated parent product ID from a pre-validated ID.
/// The caller is responsible for ensuring the parent exists via the application layer
/// (via the validate_parent_product port).
pub fn new(parent_id: product.Id) -> T {
  ValidatedParentProductId(parent_id)
}

/// Extract the validated parent product ID.
pub fn value(validated: T) -> product.Id {
  validated.id
}
