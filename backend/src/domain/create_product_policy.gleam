import domain/validated_parent_product_id

/// Business rules for product creation:
/// Parent product (if provided) must exist.
///
/// This module encodes the creation invariant as a pure domain policy.
/// Validation occurs at the port boundary; this policy confirms structural validity.
pub type CreationBlocker {
  InvalidParent
}

pub type Decision {
  CanCreate
  CannotCreate(blockers: List(CreationBlocker))
}

/// Decide whether a product can be created based on validated parent.
/// Since the parent has been validated (via port), this is a simple pass-through.
/// Provided for consistency with deletion policy and future extension.
pub fn decide(parent: validated_parent_product_id.T) -> Decision {
  case parent {
    _ -> CanCreate
  }
}

/// Check whether a product can be created.
/// Returns Ok(Nil) if all creation preconditions are met.
pub fn can_create(
  parent: validated_parent_product_id.T,
) -> Result(Nil, CreationBlocker) {
  case decide(parent) {
    CanCreate -> Ok(Nil)
    CannotCreate([first, ..]) -> Error(first)
    CannotCreate([]) -> Ok(Nil)
  }
}
