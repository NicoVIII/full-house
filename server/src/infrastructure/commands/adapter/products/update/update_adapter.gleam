import application/commands/products/update/ports
import application/shared/infrastructure_error
import domain/products/product
import gleam/dynamic/decode
import gleam/list
import gleam/result
import sqlight

fn update_attempt_decoder() -> decode.Decoder(Int) {
  decode.field(0, decode.int, decode.success)
}

fn update_product_row(
  snapshot: product.Snapshot,
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "
      UPDATE products
      SET name = ?, parent_product_id = ?
      WHERE id = ?
      RETURNING 1
      ",
      on: connection,
      with: [
        sqlight.text(snapshot.name),
        sqlight.nullable(sqlight.text, snapshot.parent_product_id),
        sqlight.text(snapshot.id),
      ],
      expecting: update_attempt_decoder(),
    )

  case query_result {
    Ok([1]) -> Ok(Nil)
    Ok(_) -> Error(infrastructure_error.DatabaseFailure)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

fn remove_all_barcodes(
  snapshot: product.Snapshot,
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  sqlight.query(
    "
    DELETE FROM product_barcodes
    WHERE product_id = ?
    ",
    on: connection,
    with: [sqlight.text(snapshot.id)],
    expecting: decode.success(0),
  )
  |> result.map(fn(_) { Nil })
  |> result.map_error(fn(_) { infrastructure_error.DatabaseFailure })
}

fn insert_barcodes(
  snapshot: product.Snapshot,
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  snapshot.barcodes
  |> list.try_map(fn(barcode) {
    sqlight.query(
      "
      INSERT INTO product_barcodes (product_id, barcode)
      VALUES (?, ?)
      ",
      on: connection,
      with: [
        sqlight.text(snapshot.id),
        sqlight.text(barcode),
      ],
      expecting: decode.success(1),
    )
    |> result.map_error(fn(_) { infrastructure_error.DatabaseFailure })
  })
  |> result.map(fn(_) { Nil })
}

fn replace_barcodes(
  snapshot: product.Snapshot,
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  use _ <- result.try(remove_all_barcodes(snapshot, connection))
  insert_barcodes(snapshot, connection)
}

fn update_product(
  product: product.T,
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  use _ <- result.try(
    sqlight.exec("BEGIN TRANSACTION", on: connection)
    |> result.map_error(fn(_) { infrastructure_error.DatabaseFailure }),
  )

  let rollback = fn(error: infrastructure_error.T) {
    case sqlight.exec("ROLLBACK", on: connection) {
      Ok(_) -> Error(error)
      Error(_) -> Error(infrastructure_error.DatabaseFailure)
    }
  }

  let snapshot = product.to_snapshot(product)

  case update_product_row(snapshot, connection) {
    Error(error) -> rollback(error)
    Ok(_) ->
      case replace_barcodes(snapshot, connection) {
        Error(error) -> rollback(error)
        Ok(_) ->
          sqlight.exec("COMMIT", on: connection)
          |> result.map_error(fn(_) { infrastructure_error.DatabaseFailure })
      }
  }
}

pub fn new(connection: sqlight.Connection) -> ports.Update {
  fn(product) { update_product(product, connection) }
}
