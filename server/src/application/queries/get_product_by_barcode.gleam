import application/queries/common/product_query_model
import application/shared/infrastructure_error
import domain/products/barcodes/barcode

pub type GetProductByBarcodeError {
  ProductNotFound
  InfrastructureError(infrastructure_error.T)
}

pub type GetProductByBarcodePort =
  fn(barcode.T) -> Result(product_query_model.T, GetProductByBarcodeError)

pub fn execute(
  for barcode: barcode.T,
  port get_product_by_barcode: GetProductByBarcodePort,
) -> Result(product_query_model.T, GetProductByBarcodeError) {
  get_product_by_barcode(barcode)
}
