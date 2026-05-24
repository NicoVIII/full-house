import application/shared/infrastructure_error
import domain/products/barcodes/barcode
import gleam/dynamic/decode
import sqlight

fn check_conflicting_product_name(
  product_barcode: barcode.T,
  connection: sqlight.Connection,
) -> Result(Bool, infrastructure_error.T) {
  let decoder = decode.field(0, decode.string, decode.success)

  let query_result =
    sqlight.query(
      "
      SELECT p.name
      FROM product_barcodes pb
      INNER JOIN products p ON p.id = pb.product_id
      WHERE pb.barcode = ?
      LIMIT 1
      ",
      on: connection,
      with: [sqlight.text(barcode.to_value(product_barcode))],
      expecting: decoder,
    )

  case query_result {
    Ok([_]) -> Ok(True)
    Ok([]) -> Ok(False)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
    // nolint: avoid_panic
    Ok(_) -> panic as "Unexpected result format for barcode assignment query"
  }
}

pub fn new(connection: sqlight.Connection) {
  fn(product_barcode) {
    check_conflicting_product_name(product_barcode, connection)
  }
}
