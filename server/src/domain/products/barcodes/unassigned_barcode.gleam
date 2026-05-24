import domain/products/barcodes/barcode
import gleam/bool

pub opaque type T {
  UnassignedBarcode(barcode: barcode.T)
}

pub type Error {
  AlreadyAssigned
}

pub fn prove(
  barcode barcode: barcode.T,
  assigned assigned: Bool,
) -> Result(T, Error) {
  use <- bool.guard(assigned, Error(AlreadyAssigned))
  Ok(UnassignedBarcode(barcode))
}

pub fn to_barcode(unassigned_barcode: T) -> barcode.T {
  let UnassignedBarcode(barcode) = unassigned_barcode
  barcode
}

pub fn to_value(unassigned_barcode: T) -> String {
  let UnassignedBarcode(barcode) = unassigned_barcode
  barcode.to_value(barcode)
}
