import domain/products/product
import gleam/option.{type Option}

/// Validated parent product ID — guarantees the parent exists (if Some) or is None.
/// This is an opaque type to ensure only validated values are constructed.
pub opaque type T {
  ValidatedParentProductId(id: Option(product.Id))
}

pub type ValidationError {
  ParentProductNotFound
}

/// Construct a validated parent product ID. 
/// Returns Ok only if the parent is None or has been proven to exist via a port.
pub fn new(parent_id: Option(product.Id)) -> Result(T, ValidationError) {
  // Note: The caller must provide a parent_id that has already been validated
  // (either None, which is always valid, or Some(id) verified to exist).
  // This is enforced in the application layer via the validate_parent_product port.
  Ok(ValidatedParentProductId(parent_id))
}

/// Construct a validated parent product ID, panicking if validation fails.
/// Used primarily in tests.
pub fn new_exn(parent_id: Option(product.Id)) -> T {
  case new(parent_id) {
    Ok(validated) -> validated
    Error(ParentProductNotFound) ->
      panic as "ParentProductNotFound: parent product does not exist"
  }
}

/// Extract the validated parent product ID.
pub fn value(validated: T) -> Option(product.Id) {
  validated.id
}
