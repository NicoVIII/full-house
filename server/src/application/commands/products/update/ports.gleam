import application/shared/infrastructure_error
import common/product_id
import domain/products/barcodes/barcode
import domain/products/product

pub type LoadProductError {
  LoadProductNotFound
  LoadProductInfrastructureError(infrastructure_error.T)
}

pub type LoadProduct =
  fn(product_id.T) -> Result(product.T, LoadProductError)

/// Returns true if the product with the given id exists, false if it doesn't
pub type ProductExistence =
  fn(product_id.T) -> Result(Bool, infrastructure_error.T)

/// Returns true if the barcode is assigned to another product, false if it is not
pub type BarcodeAssignment =
  fn(barcode.T) -> Result(Bool, infrastructure_error.T)

pub type Update =
  fn(product.T) -> Result(Nil, infrastructure_error.T)

pub type T {
  Ports(
    load_product: LoadProduct,
    does_product_exist: ProductExistence,
    is_barcode_assigned: BarcodeAssignment,
    update: Update,
  )
}
