import application/shared/infrastructure_error
import common/product_id
import domain/products/barcodes/barcode
import domain/products/product

/// Returns true if the product with the given id exists, false if it doesn't
pub type ProductExistence =
  fn(product_id.T) -> Result(Bool, infrastructure_error.T)

/// Returns true if the barcode is assigned to another product, false if it is not
pub type BarcodeAssignment =
  fn(barcode.T) -> Result(Bool, infrastructure_error.T)

pub type CreateError {
  BarcodeAlreadyAssigned(conflicting_product_name: String)
  InfrastructureError(infrastructure_error.T)
}

pub type Create =
  fn(product.T) -> Result(Nil, CreateError)

pub type T {
  Ports(
    does_product_exist: ProductExistence,
    is_barcode_assigned: BarcodeAssignment,
    create: Create,
  )
}
