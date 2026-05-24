import application/queries/common/product_query_model
import application/queries/get_product_by_barcode
import application/shared/infrastructure_error
import domain/products/barcodes/barcode
import infrastructure/queries/decoder
import sqlight

fn get_product_by_barcode(
  product_barcode: barcode.T,
  connection: sqlight.Connection,
) -> Result(
  product_query_model.T,
  get_product_by_barcode.GetProductByBarcodeError,
) {
  let query_result =
    sqlight.query(
      "
      SELECT
        p.id, p.name, p.parent_product_id,
        (SELECT GROUP_CONCAT(c.id) FROM products c WHERE c.parent_product_id = p.id) AS children_ids,
        (SELECT GROUP_CONCAT(pb2.barcode) FROM product_barcodes pb2 WHERE pb2.product_id = p.id) AS barcodes
      FROM products p
      INNER JOIN product_barcodes pb ON pb.product_id = p.id
      WHERE pb.barcode = ?
      LIMIT 1
      ",
      with: [sqlight.text(barcode.to_value(product_barcode))],
      on: connection,
      expecting: decoder.product_query_model(),
    )

  case query_result {
    Ok([model]) -> Ok(model)
    Ok([]) -> Error(get_product_by_barcode.ProductNotFound)
    Error(_) ->
      Error(get_product_by_barcode.InfrastructureError(
        infrastructure_error.DatabaseFailure,
      ))
    Ok(_) ->
      Error(get_product_by_barcode.InfrastructureError(
        infrastructure_error.DatabaseFailure,
      ))
  }
}

pub fn new(
  connection: sqlight.Connection,
) -> get_product_by_barcode.GetProductByBarcodePort {
  fn(product_barcode) { get_product_by_barcode(product_barcode, connection) }
}
